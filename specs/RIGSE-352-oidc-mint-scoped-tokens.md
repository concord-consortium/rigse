# RIGSE-352: OIDC-Minted Scoped Portal Tokens

**Jira**: https://concord-consortium.atlassian.net/browse/RIGSE-352 (epic: DT-20)

**Status**: **Closed**

## Overview

The report-service "I'm Done!" pipeline needs to act on the portal (enroll the student into an assigned class, lock the pre-test offering, notify the teacher) on behalf of the student who clicked. Instead of teaching every portal endpoint a new forwarded-student identity and a per-feature capability, the firebase function exchanges the student's forwarded Firebase token for a **scoped portal JWT** at a single minting endpoint, then makes ordinary portal API calls with that portal token. All the elevation logic lives in one place; every downstream endpoint stays as it is today, except one small new teacher-notification email endpoint.

This generalizes what the spring pilot already does (the OIDC client's mapped user simply *is* the teacher of the study classes) so it scales to the fall AI4VS RCT's roughly two dozen classes across five or more real teachers: the pipeline derives the acting teacher per-class from the student's class, rather than hardcoding one teacher. The result is reusable pipeline infrastructure: a new pipeline for any project or PI needs zero portal changes, because it mints the identity it needs and calls existing portal endpoints. The design concentrates all elevation at one auditable choke point (the mint) and leans on an audit trail rather than per-feature policy branches.

The portal is the verifier for both inputs: it verifies the OIDC service token (existing Google OIDC verifier) and the Firebase token (`SignedJwt.decode_firebase_token_by_iss` / `ForwardedFirebaseToken.verify`). The firebase function verifies nothing; it forwards. The forwarded token is a Firebase token (not a portal token) because Firebase is load-bearing on both ends of the flow: pipeline steps read student answers straight out of Firestore via `getClientFirestore(firebaseJwt)`, and the Activity Player establishes its real-time job-status session with the same token. Since a Firebase token has to exist and be forwarded regardless, reusing it as the mint input costs nothing.

## Requirements

### Mint endpoint

- `POST /api/v1/jwt/oidc_mint` (`API::V1::OidcMintController#create`) that:
  - Authenticates the caller via the existing OIDC bearer path (Google OIDC service token), and requires the OIDC client to have minting enabled via a single **boolean column** on `admin_oidc_clients` (`can_mint_scoped_tokens`, `default: false, null: false`). One gate, fail-closed by default so no existing client gains minting implicitly.
  - Requires a forwarded **Firebase student token** as a request param, and verifies it server-side.
  - Mints and returns a **scoped portal JWT** whose subject is derived only from the verified Firebase token (never from a caller-supplied user id).
- The mint may issue **only** `learner` or `teacher` scoped tokens. **No `user`/admin token minting.**
  - `learner`: the exact student named in the Firebase token. Currently unused by the `ai4vs-flvs` pipeline; kept for generic reuse.
  - `teacher`: the **least-privileged** teacher of the class the Firebase token is bound to (Q2), a bounded escalation to that class's teacher.
- The mint is called **per scope, cached for the duration of a run**. A teacher token is not class-scoped (D3) and so is reusable across steps acting on that same teacher's classes.
- The mint accepts an optional **`description`** audit label (a short string combining pipeline and step). It is **log-only**: it must never influence what is minted or any authorization decision, and must be sanitized before logging (D7).
- **Cross-class teacher mint**: the mint accepts an optional target `class_id`. It issues a teacher token for the target class **only if** the target class shares a teacher (or co-teacher) with the Firebase token's origin class, and mints the least-privileged shared teacher's token (Q2).
- The minted token carries an **audit claim** identifying it as OIDC-minted (minting OIDC client id + origin offering/class), so downstream calls made with it are attributable to a script rather than to the teacher personally.
- Elevation authority comes from the **verified Firebase token + the `can_mint_scoped_tokens` flag**, never from the OIDC client's mapped user being privileged. The arbitrary-minting bypass is closed **in code** by denying the `oidc_bearer_token` strategy on `jwt_controller`'s existing actions (D1).

### Teacher selection (Q2)

- From the eligible teacher set, prefer a teacher with **no elevated roles**; among those, pick the lowest `id` for a stable, reproducible choice. The eligible set is the origin class's teachers for an origin-class mint, or the shared-teacher intersection for a cross-class mint.
- "Elevated" means any role that widens authority beyond a plain teacher: the global `admin` / `manager` / `researcher` roles (`User#has_role?`), or project-level `is_project_admin?` / `is_project_researcher?`.
- **The mint does *not* refuse to mint for an elevated teacher.** When every eligible teacher is elevated, the mint still succeeds for the least-privileged (lowest-id) one.

### Downstream usage

- Enroll and offering-state steps use the returned token against **existing, unchanged** portal endpoints (roster / `update_student_metadata`). No new per-feature endpoints, no policy branches.
- One new endpoint: `POST /api/v1/emails/send_class_teachers`, authenticated by a portal **teacher** token (the minted teacher token via the `jwt_bearer_token` strategy, NOT OIDC):
  - Accepts `subject`, `message`, and a **required** `class_id`. Sends to **all** non-blank teacher emails of that class in one message. No "email just me" mode (Q1b).
  - **Authorization is the acting teacher's own identity:** allowed only if `current_user` is a teacher of the passed class (Pundit `class_teacher?`). A minted **learner** token is denied.
  - Reuse `oidc_send`'s input hygiene: require string `subject`/`message`; strip CR/LF from `subject`.
  - Distinct failure codes, sending nothing in every case: missing `class_id` → `400`; unresolvable `class_id` → `400`; caller not a teacher of the class → `403`; class with no non-blank teacher email → `422`; delivery failure → `502`. The nil check must precede `authorize`. Guard nil-user teachers: `class.teachers.map { |t| t.user&.email }.reject(&:blank?)`.
- Keep master's OIDC client model/table, the OIDC bearer strategy (mapped-user form), and `emails_controller#oidc_send` unchanged; the only model change is the one new boolean column. The new teacher-email action must NOT inherit `emails_controller`'s `require_oidc_auth!`.

## Technical Notes

- Rails is **8.0.1**, so `ActiveSupport::CurrentAttributes` needs no gem and auto-resets between requests.
- There is **no audit infra** in rigse today (no `audited`/`paper_trail`, no audit tables); the marker reaches only the ephemeral `Rails.logger` request lines via `auth_log_subscriber.rb`, which reads `request.env`. A persisted audit trail is out of scope.
- The "lazy Warden" trap: a `before_action` reading `request.env`/`Current` must force `current_user` first, or it runs before any strategy has stamped and silently no-ops. Standard shape: "force auth, then read the marker".
- Survivors carried from the old branch: `SignedJwt.decode_firebase_token_by_iss` + `verify_against_any`, `ForwardedFirebaseToken` (+ specs), and the `class_word` `API::V1::Offering` serializer field (REPORT-79 depends on it).
- The `class_word` serializer field is **gated on the requesting user being a teacher of the class** (or a site admin); it is withheld from the students and researchers who can otherwise read the offering. The class word is a shared enrollment secret that a teacher hands out to seed a roster and then rotates to stop students inviting friends, so serializing it to students would defeat the rotation. This does not cost REPORT-79 its single-call read: under the mint design that read is performed with an origin-class **teacher** token, which passes the gate. Note that a student can still read their own class word from `classes#show` (`ClazzPolicy#api_show?` includes `class_student?` and `get_info` returns `class_word`); that is pre-existing portal behavior, out of scope here, and worth its own story.
- The `ForwardedFirebaseToken` `:expired` reason is surfaced distinctly by the mint so report-service can separate terminal (re-click) from transient (retry) failures (D4).

## Out of Scope

- **report-service** changes: calling `oidc_mint` per scope and switching steps to the returned portal token. This spec defines the portal side of the contract only.
- **Activity Player / question-interactives** changes: none required.
- Per-class scoping of teacher tokens (D3).
- Replacing the Firebase token with a portal token as the mint input (Firebase is required by Firestore rules for the answer reads and the AP subscription).
- The `store? false` session fix (D10). Prerequisite for D9's guarantee, but a pre-existing portal-wide issue needing its own story and consumer audit.

## Not Yet Implemented

- **Portal-JWT session-storage fix (D10)** — deferred to its own story. `jwt_bearer_token_authenticatable` defines no `store?` override and `skip_session_storage` covers only `:http_auth`, so any portal JWT (including a marked, service-minted one) establishes a Rails session, after which no marker exists and the D9 propagation, the `jwt_controller` denial, and the D11 rules are all inert. This is a pre-existing portal-wide vulnerability independent of this design; the fix (`store? false`) changes behavior for every portal-JWT consumer (AP, LARA, dashboards) and needs its own consumer audit and testing. Covered here by a **pending/skipped** test (not omitted) referencing the D10 story. D9's guarantee is conditional until it lands; track it as a blocking dependency.
- **D11 mounted-engine middleware (option A)** — deferred with a tripwire. The API-namespace confinement is an `ApplicationController` `before_action` that mounted Rack engines do not run. The only mount today (`Delayed::Web::Engine` at `/delayed_job`) is session-authed and already fail-closed for bearer tokens, so building Rack middleware now would protect against zero current threat. Instead: a comment at the mount site plus a **guard spec** asserting `routes.rb` contains no `mount` beyond the known engine. **Trigger to build the middleware:** the moment any engine authenticating via a bearer/portal token is mounted.

## Decisions

### Q1 — Emailing co-teachers
**Context**: The pipeline needs to notify the teacher(s) of a class, and a class may have co-teachers.
**Decision**: Handled by the `class_id` → all-teachers mode of the new `send_class_teachers` endpoint: recipients are always all non-blank teacher emails of the passed class, in one message.

---

### Q1b — Self-send mode
**Context**: An earlier shape allowed a caller to email just the authenticated user, in addition to the class-teachers mode.
**Options considered**:
- A) Keep an optional self-send mode alongside the required-`class_id` mode.
- B) Drop self-send; make `class_id` required with no fallback recipient.

**Decision**: B. `class_id` is required; there is no self-send mode. It would add a second authorization path and recipient derivation for zero callers and dilute the endpoint's single reviewable invariant; "email the authenticated user" is already `oidc_send`'s niche. Cheap to add later if a real caller appears.

---

### Q2 — Teacher selection
**Context**: A class may have several co-teachers, and research-class co-teachers are often the PI or research staff holding elevated roles. Picking such a teacher when a plain-teacher co-teacher exists needlessly widens the token's blast radius (D2).
**Options considered**:
- A) Plain lowest-id teacher (earlier resolution).
- B) Least-privileged eligible teacher (no elevated roles), tie-broken by lowest id; refuse to mint if every eligible teacher is elevated.
- C) Least-privileged eligible teacher, tie-broken by lowest id, but **still mint** for the lowest-id elevated teacher when all are elevated.

**Decision**: C. From the eligible set (origin class's teachers, or the cross-class shared-teacher intersection), prefer a teacher with no elevated roles (`admin`/`manager`/`researcher`, or project-admin/project-researcher); among those, lowest `id` for reproducibility. The mint does **not** refuse an elevated-only class. Refusing entirely would be a support nightmare (Trudi is the sole teacher of some FLVS sections; the person testing the button is exactly who would be blocked). No "primary teacher" concept exists, so lowest `id` is the stable tie-break.

---

### Q3 — Teacher-email endpoint auth
**Context**: The teacher-email endpoint could be OIDC-authed (like `oidc_send`) or portal-token authed.
**Decision**: Portal-token (`jwt_bearer_token`) authed, using the minted teacher token, so `oidc_send` stays untouched and OIDC-only and the recipients are gated by the acting teacher's own `class_teacher?` identity.

---

### Q4 — Dedicated mint controller
**Context**: The mint could live as a new action on the existing `JwtController` or in its own controller.
**Options considered**:
- A) Add `oidc_mint` to `JwtController`.
- B) A dedicated `API::V1::OidcMintController#create`, routed as `POST /api/v1/jwt/oidc_mint`.

**Decision**: B. (a) D1's containment rests on the mint never reaching `can_access_user`, a private method in `JwtController`; in a separate class it is not even in scope. (b) `JwtController`'s class-level `rescue_from StandardError, with: :error_400` would blur the fail-closed reasons. (c) `handle_initial_auth` assumes the requesting user is the subject, the inverse of the mint's model. Common claim-building is shared via the `PortalTokenClaims` helper.

---

### Naming — `oidc_mint` endpoint, `can_mint_scoped_tokens` column, `send_class_teachers` action
**Context**: The design used working names; each was verified against master's conventions before committing.
**Decision**: Keep all three. `oidc_mint` sits in the `jwt` namespace beside `portal`/`firebase`; the `oidc_` prefix reads as "OIDC-authenticated" by analogy to `oidc_send`, and it is already the cross-repo contract. `can_mint_scoped_tokens` follows the `can_*` boolean-column precedent (`can_add_teachers_to_cohorts`, `can_manage_permission_forms`). `send_class_teachers`' deliberate absence of an `oidc_` prefix signals that it is portal-teacher-token authed, not OIDC (Q3). Wiring note: because the mint uses a separate controller but lives at `/api/v1/jwt/oidc_mint`, the route must be explicit: `post 'oidc_mint', to: '/api/v1/oidc_mint#create'` inside `namespace :jwt` (the leading-slash target reaches `API::V1::OidcMintController`).

---

### D1 — Do not require the OIDC caller to be a site admin
**Context**: The existing `jwt_controller` already mints for an arbitrary `target_user_id` when `can_access_user` is true, which returns true for any admin. If the mint OIDC client mapped to a site admin, it could mint tokens for any student via that existing path, with no Firebase token, bypassing the whole constraint. There is exactly one OIDC client row (keyed on the functions' service-account `sub`), and its mapped user must stay privileged while the spring pipeline calls portal endpoints directly, so a roleless second client is not a workable fix.
**Decision**: The mint runs on a dedicated action that never falls through to `can_access_user`, gated by `can_mint_scoped_tokens`. Additionally, **deny the `oidc_bearer_token` strategy on `jwt_controller`'s existing actions** (`portal`, `firebase`). Verified safe: report-service makes no `/api/v1/jwt` calls, and the AP reaches those actions with a portal JWT or session, never with an OIDC token. With that code guard, D1 holds regardless of the mapped user's roles, and survives someone later granting that account admin.

---

### D2 — Bounded escalation, stated precisely
**Context**: What exactly does the mint bound, given that a minted token carries whatever authority its subject already has (portal authorization reads DB roles off the reloaded User, not the JWT)?
**Decision**: The bound is on **which identity may be assumed**, not on what that identity can do. The only issuable subjects are the student named in the Firebase token, or a teacher of that student's class (or a shared teacher of an assigned class). A minted token can still be admin-capable when the chosen teacher genuinely is elevated. The compensating control is **auditability (D5)**, not restriction: the `minted_via_oidc_client_id` and `minted_for` claims distinguish "the teacher did this" from "a script acted as the teacher". Q2 (least-privileged selection) narrows the common-case blast radius without changing the model.

---

### D3 — Minted teacher token is NOT class-scoped at the auth layer (accepted)
**Context**: A minted teacher token, used through the normal `jwt_bearer_token` path, makes `current_user` that teacher, and existing teacher policies grant access to all of that teacher's classes, not just the origin one. True per-class scoping would require a class claim plus a check in the teacher policies (a portal change).
**Decision**: Accepted for v1 under the "one maintainer owns the whole chain + D9" model. Residual risk is bounded by the standard token lifetime and by D9 (a minted token cannot be re-minted into a fresh or unmarked JWT). The `open_only_write?` restriction from the abandoned branch is deliberately not preserved: P2 requires lock-current, hide-current and open-target, so a blanket open-only rule would block the fall design. **Revisit class-scoping** when either structural gate weakens: (a) minting is enabled for an OIDC client outside CC's operational control, or (b) pipeline code becomes deployable by someone who does not also own the portal side. If scoping is added, reinstating `open_only_write?` is the natural first step.

---

### D4 — WITHDRAWN (short-TTL): standard TTL for the minted token
**Context**: An earlier draft gave minted tokens a deliberately short expiry.
**Decision**: **Dropped.** It never bound anything: the Firebase input token lives 3600s and rides the Cloud Tasks payload, so anyone holding it (plus the OIDC client) can mint fresh tokens for as long as it lives. Making the output shorter than the input is theater and adds a failure mode (a token expiring mid-run). Minted tokens use the same standard TTL as any other portal token; the shared claims builder needs no TTL parameter. Bounding a leaked minted token is handled by D9 (no re-minting) plus never logging the token. **Consequence retained**: an expired Firebase input is a terminal failure (re-minting it is not available), so the mint must surface the `:expired` reason distinctly (its own error code, separable from `:signature`, `:not_learner`, etc.) so report-service can treat expiry as terminal and other failures as retryable.

---

### D5 — Auditability via a token claim, not just mint logging
**Context**: D2 accepts that minted tokens carry full teacher authority and names auditability as the compensating control, so the audit trail must reach downstream calls, not just the mint call.
**Decision**: Log the mint call, AND stamp a claim on the minted token so the `jwt_bearer_token` request-auth logging records that downstream calls were made by a script-minted token. The claim carries the caller's `description` label too, giving a full trace: mint log → token claim → downstream request log.

---

### D6 — The teacher-email endpoint is gated by the acting teacher's identity
**Context**: How to ensure a caller can never email a class they do not teach and never supplies a raw recipient address.
**Decision**: Recipients are always all teachers of the passed class, and the class is authorized by `class_teacher?`. There is no self-send fallback (Q1b), so there is exactly one recipient rule and no request field ever names a recipient. A learner token cannot use it.

---

### D7 — The `description` audit label is untrusted, log-only input
**Context**: The `description` is caller-supplied free text.
**Decision**: Never read it as an authorization input or use it to select what is minted. Sanitize before logging or embedding: cap length (100) and strip CR/LF (`value.to_s[0, 100].gsub(/[\r\n]/, ' ')`), so a caller cannot forge log lines. A missing label logs as `(none)` rather than failing the mint.

---

### D8 — WITHDRAWN: minted tokens carry the subject's normal claims
**Context**: An earlier draft required suppressing `add_admin_claims` and stamping `admin: -1` / `project_admins: []` on minted tokens.
**Decision**: **Withdrawn.** (1) It does not restrict anything, because portal authorization reads DB roles, not JWT claims, so an admin teacher's token stays admin-capable. (2) It would make the token lie about its subject to downstream consumers (Firebase rules, report-service, other CC apps), a gratuitous divergence from what `jwt_controller#portal` already emits. The mint uses normal claim building, unchanged; the shared builder needs no `admin_claims` parameter. If a minted token ever needs to be constrained, the lever is scoping (D3's revisit trigger), never claim suppression.

---

### D9 — The audit marker must survive every token derivation
**Context**: D2 names auditability as the compensating control, so a path that yields an unmarked token defeats that control and allows indefinite refresh. On master there are five `create_portal_token` call sites, two of which (`home#authoring_site_redirect`, `classes#log_links`) put a fresh token into a response for a caller who passed a teacher/admin policy, i.e. real laundering holes.
**Decision**: Two mechanisms. **Mechanism 1 — propagate at the choke point**: all five sites go through `SignedJwt.create_portal_token`, so the marker is propagated there via a request-scoped `Current`, set in both decode paths (the Warden strategy and `api_controller#check_for_auth_token`) and read when signing. Because `create_portal_token` merges with a block that raises on duplicate keys, propagation uses `||=` semantics (the mint sets the marker explicitly at origin). **Mechanism 2 — deny outright at `jwt_controller`** (`portal` and `firebase`) for any caller whose token carries the marker; re-minting there is never legitimate and it is the one place a caller could pivot to a different user or obtain a Firebase token. This closes **JWT-to-JWT** laundering only; conversion to a non-JWT credential is D10.

---

### D10 — KNOWN GAP (accepted, deferred): a marked token can still become a non-JWT credential
**Context**: Two verified paths outside the JWT choke point convert a marked token into a durable, unmarked credential: (1) a Rails session (`jwt_bearer_token_authenticatable` calls `success!` with no `store?` override, and `skip_session_storage` covers only `:http_auth`), and (2) an OAuth `AccessGrant`.
**Decision**: The **session fix is deferred to its own story**; D9's guarantee is conditional until it lands (see "Not Yet Implemented"). The `AccessGrant` path is closed now by D11 rule 2. While the session gap is open: do not describe D9 as making the audit trail unlaunderable; D3's "never persisted" bound does not hold; the D11 rules are defense in depth, not the primary control; and the session fix is tracked as a blocking dependency. The gap is captured as a pending/skipped test rather than omitted.

---

### D11 — A marked token is valid only within the API namespace, and may never create an `AccessGrant`
**Context**: Even with D9, a marked token reaching the Devise identity surface (registrations, passwords, confirmations, omniauth linking), the OAuth authorize/token endpoints, or `home#authoring_site_redirect` could change the teacher's password/email or mint an unmarked credential.
**Decision**: Two fail-closed rules. **Rule 1 — namespace confinement**: an `ApplicationController` `before_action` rejects any request carrying `Current.minted_via_oidc_client_id` that is not under the API namespace (skipped for `API::APIController`). Chosen over enumerating credential routes because it fails closed for routes nobody has written yet; pipeline work lives in the API namespace, so a new pipeline feature still needs no portal change. **Rule 2 — `AccessGrant` refusal at the model**: a `before_create` on `AccessGrant` refuses when `Current.minted_via_oidc_client_id` is present, covering any caller rather than any one route.

---

### D11 mounted-engine coverage — defer with a tripwire
**Context**: The API-namespace confinement (D11 rule 1) is an `ApplicationController` `before_action` that mounted Rack engines do not run. The only mount is `Delayed::Web::Engine` at `/delayed_job`.
**Options considered**:
- A) Rack middleware ahead of the router (future-proof, but must force `warden.authenticate` itself, re-triggering the D10 session-store behavior, on every non-API request).
- B) Wrap each engine's route constraint.
- C) Both.

**Decision**: Defer (neither A nor B nor C now), with a tripwire. Verified: the engine is session-authed and already fail-closed for bearer tokens (`Warden::Proxy#user` reads the session only, so a marked bearer token with no session gets `warden.user == nil` → 404 before any engine code runs); reaching it requires a session first, which is D10's gap, at which point the marker is already lost. So a `Current`-based wrapper would detect nothing and middleware would protect against zero current threat. Instead: keep the `ApplicationController` filter for normal routes, add a comment at the mount site, and add a guard spec asserting `routes.rb` contains no `mount` beyond the known engine. **Trigger to build the middleware (A):** the moment any engine authenticating via a bearer/portal token is mounted.
