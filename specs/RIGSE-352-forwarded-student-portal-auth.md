# Forwarded-Student Portal Auth

**Jira**: https://concord-consortium.atlassian.net/browse/RIGSE-352

**Status**: **Closed**

## Overview

When a student clicks an "I'm Done" button in a study activity, an automated report-service job calls back into the portal to move the student between classes, lock or unlock their activities, and notify their teacher. Previously all of those calls ran as one fixed high-privilege account, so the automated job could reach any student's data. This story makes each call act as the specific student who clicked, with only that student's access, while still requiring verified proof that the call came from the sanctioned service.

Every report-service portal call now acts as the **verified student**, using two credentials that are **both required**:

1. **The existing OIDC service token** proves the request came from the trusted report-service caller. It no longer selects a user.
2. **The student's portal-minted Firebase learner JWT**, forwarded by report-service on each call (in the `X-Portal-Student-JWT` header), establishes who to act as.

The portal verifies the forwarded learner JWT and sets `current_user` to that student. Because a `Portal::Learner` ties one student to one offering (and thus one class), the token carries both the acting identity (`claims.platform_user_id`) and the verified origin context (`claims.offering_id`, `claims.class_hash`), so per-operation checks anchor to that verified origin rather than granting the full student identity free rein.

Neither token alone is sufficient. A student's Firebase JWT without the trusted-service OIDC token must never authorize these operations, and a present-but-invalid forwarded token fails closed and never falls back to the mapped user.

It ships in two phases so existing spring behavior is preserved during the transition, with the high-privilege fallback removed only after the new path is verified in production. It is the first and blocking piece of the fall randomized-controlled-trial work spanning three repositories (portal, report-service, question-interactives).

## Requirements

### Forwarded-student authentication

- The portal accepts, on report-service's portal calls, an additional forwarded student learner (Firebase) JWT alongside the existing OIDC service token, carried in the **`X-Portal-Student-JWT`** request header (raw token, no `Bearer` prefix). This header name is the cross-repo contract with report-service (REPORT-83).
- When a valid forwarded student learner JWT is present on an OIDC-authenticated report-service request, the OIDC auth path sets `current_user` to the student named by the token's `claims.platform_user_id` (an integer nested under `claims`), not to any mapped/admin user.
- The forwarded-student override is **scoped to an opted-in OIDC client**, honored only when the resolved client declares lifecycle capabilities or requires the forwarded JWT (`capabilities.present? || requires_forwarded_jwt?`). For a non-opted-in client the forwarded header is **ignored** and the client authenticates as its mapped user (existing behavior). The fail-closed-on-present-header rule applies only to opted-in clients.
- The forwarded token is verified to be a **learner** token as a fail-closed rule: `claims.user_type == "learner"` **and** the resolved user has a `portal_student`. Otherwise the request fails closed with `forwarded_token_invalid`.
- Before trusting the token, the portal confirms `claims.platform_id` matches this portal's `APP_CONFIG[:site_url]` (replay defense across portals).
- The origin offering and class are resolved from `claims.offering_id` as the **single canonical anchor**: origin offering = offering with id `claims.offering_id`; origin class = `offering.clazz`. All three resolutions (user, offering, clazz) **fail closed as `401 forwarded_token_invalid`** on a missing/nil record (via `find_by`, never a bang `find` that would surface as 404, nor a nil `clazz` NoMethodError as 500). `claims.class_hash` is a **cross-check only**: if `offering.clazz.class_hash != claims.class_hash` the request fails closed. No operation resolves the origin class by `class_hash` lookup.
- The forwarded learner JWT is verified (signature and expiry) using the portal's own Firebase signing key with **zero clock-skew leeway** (no `exp_leeway`), intentional because the portal both mints and re-verifies on its own clock. The verifying `FirebaseApp` is resolved from the token's `iss` claim (= the app's `client_email`); if `client_email` is ever non-unique, RSA-key selection stays deterministic by verifying against each `iss`-matched candidate and accepting the one whose key validates.
- The resolved app must be a member of a configured allowlist of trusted app name(s) (default: the report-service apps). Config-only; no schema/admin-form change.
- The origin context (`offering_id`, `class_hash`) is made available to the authorization layer via `request.env` stamps so per-operation checks anchor to the verified origin.
- When the forwarded token is expired or otherwise invalid, the portal fails closed with a **distinguishable** error (see the error contract below), keyed on the header being **present**; only total **absence** of the header engages the Phase 1 legacy fallback.
- **Distinguishable-error contract** (shared with REPORT-83), the `error_code` a **top-level** JSON key (`{ success:false, response_type:"ERROR", error_code:"...", message:"..." }`):
  - **HTTP 401** `error_code: "forwarded_token_invalid"` — forwarded token present but fails any check (signature, expiry, `platform_id`, app allowlist, or any token-asserted record resolution / `class_hash` mismatch). Never a bare 404/500.
  - **HTTP 401** `error_code: "oidc_token_invalid"` — OIDC service token invalid / no matching client / inactive.
  - **HTTP 401** `error_code: "forwarded_token_required"` — Phase 2 only: `requires_forwarded_jwt` set but the header is absent.
  - **HTTP 403** `{ success:false, message:"Not authorized" }` — capability/per-operation authorization denial (existing Pundit path, unchanged).
- The forwarded-invalid response must fail closed as an authentication `401` and must **not** degrade into the `403` authorization-denial signal. Because these endpoints have no `authenticate_user!` filter and the strategy fails non-bang, this is actively enforced by controller-level detect-and-render, not by strategy `fail!` alone.
- The auth layer continues to stamp request metadata (`portal.auth_strategy`, `portal.auth_client`, `portal.auth_details`) plus the client id and forwarded-origin claims.
- The rewritten strategy declares `store? => false` (no session serialization of the per-request student) and sets `request.env['devise.skip_trackable'] = true` before `success!` on the forwarded path (so acting-as-student never overwrites the real student's Devise sign-in tracking).

### OIDC client migration

- `admin_oidc_clients.user_id` is made nullable (`change_column_null(..., true)`; no FK to drop). This Phase-1-safe schema change is separate from the Phase-2 data change that nulls the value.
- `Admin::OidcClient` gains a `requires_forwarded_jwt` flag (`default: false, null: false`). When set, the client cannot authenticate without a valid forwarded student JWT (no mapped-user fallback).
- `validates :user, presence: true` is made **conditional** (`unless: :requires_forwarded_jwt?`), not removed, so a legacy/fallback client still requires a mapped user while a flipped Phase-2 client may have a null user. No `belongs_to optional:` change needed (`belongs_to_required_by_default = false` app-wide).

#### Generic per-operation capabilities

- `admin_oidc_clients` gains a generic `capabilities` set column (`serialize :capabilities, type: Array`, following the `enabled_bookmark_types` precedent). No feature-specific column.
- Recognized capabilities are declared once in `Admin::OidcClient::CAPABILITIES` (frozen `identifier => label` hash), the sole source of truth: `enroll_student`, `update_offering_state`, `send_teacher_email`.
- `Admin::OidcClient#capability?(name)` returns membership, treating unset/`nil` capabilities as the empty set (never raises).
- The model validates that every stored capability is a key of `CAPABILITIES` (no-ops cleanly on nil/empty).
- The admin CRUD form renders one checkbox per registered capability (label as help text); permitted params accept the `capabilities` set.
- A capability grants permission to invoke that operation; it never elevates the acting identity to a teacher. The migrated client is granted exactly `enroll_student`, `update_offering_state`, `send_teacher_email`.

### Authorization (current_user is always the student)

- The forwarded-student branch lives on a **new, action-scoped** `Portal::OfferingPolicy#update_student_metadata?` (not the shared `update?`), dispatching **exclusively** to the forwarded branch when acting as the forwarded student, else `class_teacher_or_admin?`. The controller action is repointed to `authorize offering, :update_student_metadata?`. The bare `update?` (used by `offerings#update`) stays teacher/admin-only. The two branches are mutually exclusive by auth path, not additive, so a forwarded token whose user is independently a teacher/admin is still bound to student-scope.
- Likewise a new **action-scoped** `Portal::ClazzPolicy#add_to_class?` (not shared `update_roster?`), dispatching exclusively to the forwarded enroll branch. The controller is repointed to `authorize portal_clazz, :add_to_class?`; `remove_from_class` stays on the bare `update_roster?`. The follow-on `authorize student, :show?` is retained as defense-in-depth but is no longer the load-bearing identity guard; `forwarded_enroll_student?` binds the target to the acting student on **every** provided identifier (`user_id` and/or `student_id`).
- Each policy branch checks the capability naming its own operation.
- Trusted-path detection resolves the client by a **stable id** (`portal.auth_client_id`), never by `portal.auth_client` (name, which has no uniqueness), and goes through the shared `OidcAuthContext` helpers.

### Reusable auth helpers (shared with RIGSE-353)

- A single generic `OidcAuthContext` PORO in `lib/`, constructible from a request **or** an env hash, exposes `#client`, `#acting_as_forwarded_user?`, `#origin_offering_id` / `#origin_class_hash`, `#origin_offering` / `#origin_clazz` (resolved via `find_by`), and `#capability?(name)`.
- `ApplicationPolicy` gains a memoized `oidc_context` accessor as a convenience for policies in that hierarchy. The existing `API::V1::EmailPolicy` (a Struct) is not refactored; RIGSE-353's `teacher_send` may extend `ApplicationPolicy` or build the PORO directly.
- The pure capability predicate stays on the model; the strategy stamps enough on `request.env` for the PORO to resolve everything.

### Per-operation access checks (forwarded-student branch only)

- **Lock or hide the current offering** (`update_offering_state`): allowed when the target offering is the token's origin `offering_id` **and** the target `user_id` equals the acting student.
- **Open a target offering** (`update_offering_state`): allowed when the target `user_id` equals the acting student, the target offering belongs to a class the student is enrolled in, and the written values are **open-only**. For a non-origin offering the branch **denies** any write that sets `locked:true` or `active:false` (only unlock / make-visible off-origin). Booleans are **cast** (`ActiveModel::Type::Boolean`) so `"true"`/`"1"`/`1`/`true` are all caught; an empty write (no `locked`/`active` key) is denied.
- **Enroll into a class** (`enroll_student`): allowed when the target class shares at least one teacher with the origin class (`(origin_clazz.teachers & target_clazz.teachers).any?`, comparing against any teacher) and the target class is not archived. Accepted residual risk: this admits any non-archived class taught by any origin co-teacher; enroll only ever adds the acting student themselves, and the target class is already fully controlled by the origin teacher.
- **Reading the student's own answers**: already runs as the student via the forwarded token; enforced by Firestore rules. No portal change.
- **Resolve the origin class word** (O14 reads): `offerings/:id` then `classes/:id` are already permitted for the acting student (`api_show?` allows `class_student?`); no new policy or capability.

### Origin-class-word resolution convenience (O14)

- `class_word` is exposed on the `API::V1::Offering` show serializer so report-service resolves the origin class word from a single `offerings/:id` read. (Optional optimization; delivered.)

### Two-phase rollout

- **Phase 1**: the auth layer accepts either credential path; the fallback is gated on the **absence** of the header. Header present but unverifiable → fail closed with the distinguishable error, never the mapped user. Both the header-absent fallback and the present-but-invalid signal are logged/metriced distinctly (fact + reason only, never the raw JWT), the header-absent-but-OIDC-present rate being the tripwire for a proxy stripping the header.
- **Cross-repo sequencing**: the override is global across the opted-in client's endpoints, so report-service must switch the notify step to `teacher_send` (RIGSE-353) or stop forwarding the header on the notify call before the override goes live, else teacher notifications misroute to students. No RIGSE-352 code change.
- **Phase 2**: the client is flipped to `requires_forwarded_jwt = true` with `user_id = null`, removing the legacy fallback. A header-absent call then fails closed as `401 forwarded_token_required`.

**Per-phase data state of the one `Admin::OidcClient` record:**

| Field | Phase 1 (code deployed) | Phase 2 (fallback removed) |
|---|---|---|
| `user_id` | mapped user (unchanged) | `null` |
| `requires_forwarded_jwt` | `false` (column default) | `true` |
| `capabilities` | `[enroll_student, update_offering_state, send_teacher_email]` | same |

The schema migration + capability grant ship together (Phase-1-safe). The `user_id -> null` / `requires_forwarded_jwt -> true` flip is a separate Phase-2 data step (rake task), gated on report-service forwarding in production and the notify step having moved off `oidc_send`.

### Acceptance criteria

- Report-service portal calls act as the student; after Phase 2 no action runs as the legacy mapped user.
- After Phase 2 the service client cannot authenticate without a valid forwarded student Firebase JWT.
- A student cannot perform these lifecycle operations by calling the portal directly without report-service's service token.
- Existing production (spring) report-service behavior is preserved through the migration.

## Technical Notes

- **OIDC strategy** (`rails/lib/oidc_bearer_token_authenticatable.rb`): `valid?` peeks the unverified issuer to claim the `Authorization` header; `oidc_token_value` declines `Bearer/JWT`. The forwarded header does not participate in this routing. Rewrite adds `store? => false`, `devise.skip_trackable`, the opt-in gate, phase handling, and machine `portal.auth_error` stamping.
- **Devise `:trackable`**: `store? => false` gates only session serialization; the separate `after_set_user` trackable hook still fires `update_tracked_fields!` unless `request.env['devise.skip_trackable']` is set. Without the flag, every report-service call would inflate the acting student's `sign_in_count` and overwrite `last_sign_in_at`/`_ip`.
- **Firebase verify/mint** (`rails/lib/signed_jwt.rb`): `decode_firebase_token_by_iss` selects the RSA key from the token `iss`, verifying signature + `exp` with zero leeway. `CLOCK_SKEW_ALLOWANCE = 30` is a mint-time `iat` backdate only.
- **Firebase claim shape**: nested `claims` carries `platform_id` (= site_url), `platform_user_id` (integer = `user.id`), and for a learner token `user_type:"learner"`, `offering_id`, `class_hash`. Identity resolution uses `platform_user_id`, not the MD5 `uid`. `user_type:"learner"` is the learner-exclusive discriminator.
- **Error rendering**: `API::APIController#error` gains a **positional** trailing `error_code` param (a keyword param would break existing hash-style callers `error(class_word: ...)`). A `ForwardedAuthGuard` concern (`prepend_before_action`, scoped to the guarded action) forces the Warden chain and renders `401 + error_code` from `request.env['portal.auth_error']` before Pundit turns a nil user into a 403.
- **Token lifetime**: hard ~1-hour life, effectively ~3570s after the 30s `iat` backdate. The portal cannot extend or re-mint it; report-service must call within the token's life (a REPORT-83 concern).
- **Testability**: forwarded-path specs mint via `spec/support/firebase_test_helper.rb` (`FirebaseApp` name `"test app"`, `client_email "user@example.com"`); specs add the test app to the allowlist (or name it an allowlisted name).

## Out of Scope

- The `teacher_send` email endpoint itself (RIGSE-353 / story R2), though this story delivers the shared student-auth path and reusable helpers it runs on.
- report-service changes (REPORT-83 and the fall report-service stories): forwarding the token, switching the notify step to `teacher_send`, resolving target class words.
- A persisted audit trail (none exists today; only `Rails.logger` lines improve).
- Leaving `oidc_send` in place unchanged (carries the rollout-ordering obligation above, but is not modified here).
- Scheduled unlocking (manual for v1).
- Any change to the OIDC token-minting side in report-service.
- Origin-class-word resolution logic and program dispatch (report-service REPORT-79/REPORT-82); this story only exposes `class_word` on the serializer and ensures the reads are permitted.

## Decisions

### What is the exact "sanctioned destination class" rule for enroll?
**Context**: Enroll is the one operation where the student is not yet a member of the target class, so an ownership check cannot apply, and there is no class-to-class model relationship.
**Options considered**:
- A) Origin-anchored shared-teacher rule: allow only when the target class shares at least one teacher with the token's origin class, plus not-archived.
- B) Class-word suffix rule (`-Gator`/`-Shark`): pushes a report-service/authoring naming convention into a portal policy (wrong layer, brittle to renames).
- C) Same-project rule: broader, needs project wiring the study does not require.

**Decision**: **A**, comparing against **any** teacher of the origin class (co-teachers are equally trusted), target class not archived. The origin class is resolved from `claims.offering_id` via `offering.clazz`, with `class_hash` as a fail-closed cross-check, so no naming convention is encoded in the portal. Option C is the intended future broadening if a tighter boundary is ever needed.

### How is the capability modeled on the client, and how granular?
**Context**: The `Admin::OidcClient` table is generic auth infrastructure, and controllers ask a per-operation question.
**Options considered**:
- A) Single boolean on the client: bakes a feature-specific column into a generic table.
- B) Generic named-capability set (`serialize :capabilities, type: Array`), one identifier per operation, checked via `capability?(:op)`.
- C) Single boolean behind a `capability?` shim.

**Decision**: **B**. Generic `capabilities` column; recognized identifiers declared once in `Admin::OidcClient::CAPABILITIES` (`enroll_student`, `update_offering_state`, `send_teacher_email`); `capability?(name)` is the model predicate. Also satisfies RIGSE-353 (`send_teacher_email`).

### Where do the shared OIDC/capability helpers live, and what is their surface?
**Context**: RIGSE-352 and RIGSE-353 both need to detect the trusted OIDC path and check capabilities without duplicating `request.env` lookups.
**Options considered**:
- A) Generic PORO (`OidcAuthContext` in `lib/`) plus a thin memoized `ApplicationPolicy#oidc_context` accessor.
- B) Policy mixin + controller concern: requires new `concerns` dirs, splits logic across two mixins.
- C) Model predicates only, policies read `request.env` directly: re-duplicates the stamp-reading.

**Decision**: **A**. `OidcAuthContext` (request-or-env constructor) is the canonical shared surface; the `ApplicationPolicy` accessor is convenience-only. The existing Struct `EmailPolicy` is not refactored.

### In what header does report-service forward the student learner JWT?
**Context**: `Authorization: Bearer` carries the OIDC token, so the forwarded JWT needs a separate, non-colliding transport. The name is a REPORT-83 contract.
**Options considered**:
- A) `X-Forwarded-Firebase-JWT` (raw token): self-documenting but sits in the `X-Forwarded-*` namespace proxies commonly strip.
- B) A token-tech-neutral name.
- C) `X-Forwarded-Authorization: Bearer <token>`: unnecessary scheme ceremony.

**Decision**: **`X-Portal-Student-JWT`** (raw token, no `Bearer`), deliberately off the `X-Forwarded-*` namespace to reduce the proxy-stripping / fail-open-to-admin exposure. Cross-repo contract REPORT-83 must match. The Phase-1 observability tripwire (rising header-absent-but-OIDC-present rate) is retained as residual-risk defense.

### How does the portal know which FirebaseApp key to verify the forwarded token against?
**Context**: The token's `iss` equals the app's `client_email`, which already exists on `firebase_apps`.
**Options considered**:
- A) Derive the app from `iss`/`client_email`, verify against that app's key, optionally pin to a config allowlist.
- B) A single configured app name: hardcodes one app per env.
- C) report-service forwards the app name: extra cross-repo coupling for no benefit.

**Decision**: **A with a config allowlist**. Resolve the `FirebaseApp` from `iss` and verify against its RSA key; require the resolved app to be in a config-only name allowlist. `client_email` is assumed unique (unenforced); if that breaks, verify against each `iss`-matched candidate and accept the one whose key validates.

### Is forwarded-JWT expiry a risk given the async flow, and must this story address it?
**Context**: The token has a hard ~1-hour life baked into the Cloud Task body; the portal cannot re-mint it, and report-service swallows step failures without redelivery.
**Options considered**:
- A) Fail closed, define nothing extra: indistinguishable from any other 401.
- B) Fail closed with a distinguishable error; record the timing assumption as a REPORT-83 concern.
- C) Widen skew/lifetime: weakens the credential and cannot fix a genuinely old token.

**Decision**: **B**. Fail closed with a distinguishable "forwarded token expired/invalid" error; the cross-repo timing assumption is a REPORT-83 responsibility.

### Fail-closed vs the Phase-1 fallback for a present-but-invalid forwarded token
**Decision**: The Phase-1 legacy fallback is gated on **absence** of the header. A present-but-unverifiable forwarded token fails closed with the distinguishable error in **both** phases and never reaches `success!(oidc_client.user)`, so an invalid student credential can never escalate to the mapped admin. The present-but-invalid case is logged distinctly as the early signal of in-flight expiry or replay.

### "Open a target offering" scope and the off-origin value constraint
**Decision**: Both lock and open require the target `user_id` to equal the acting student (closing an act-as-A-touch-B hole). Enrollment-wide scope for "open" is intentional; the target-user guard confines the blast radius. The value constraint was **promoted to a v1 requirement**: a non-origin target offering may not be written `locked:true`/`active:false`, and booleans are cast so string and JSON forms are both caught. An empty write (no state key) is denied (else the controller's `find_or_create_by` would materialize a defaulted metadata row before `permit`).

### Nulling `user_id`: schema migration + conditional validation
**Decision**: Requires a `change_column_null(:admin_oidc_clients, :user_id, true)` migration (column was `NOT NULL`; no FK to drop) plus making `validates :user, presence: true` **conditional** (`unless: :requires_forwarded_jwt?`), not removed (blanket removal would permit an invalid `requires_forwarded_jwt=false` + null-user client). No `belongs_to optional:` needed (`belongs_to_required_by_default = false`).

### `student :show?` is defense-in-depth, not the identity guard
**Decision**: The forwarded branch is dispatched **exclusively** (never OR-ed with `update_roster?`), and `forwarded_enroll_student?` binds the target to the acting student on every provided `user_id`/`student_id`. `Portal::StudentPolicy#show?` also passes via admin/teacher-of-record/project-admin, so it cannot alone deny enrolling a different student under a forwarded token whose user holds those roles; it is retained only as defense-in-depth.

### Zero clock-skew leeway on the forwarded decode
**Decision**: Firebase decode enforces `exp` with zero leeway, intentionally, because the portal mints and re-verifies its own token on its own clock. No `exp_leeway` added.

### Distinguishable-error contract and its rendering mechanism
**Decision**: A three-signal 401 contract (`forwarded_token_invalid`, `oidc_token_invalid`, `forwarded_token_required`) plus the existing 403 authorization denial, with `error_code` a **top-level** JSON key. Because the in-scope endpoints have no `authenticate_user!` filter and the strategy fails non-bang (so a strategy `fail!` never reaches `CustomFailure`), the mechanism is **controller-level detect-and-render**: the strategy stamps `portal.auth_error` and a `ForwardedAuthGuard` `prepend_before_action` renders the 401 before Pundit. `error_code` is added as a **positional** param on `API::APIController#error` (a keyword param would break existing hash-style callers).

### Origin offering/clazz resolution must fail closed as 401
**Decision**: All forwarded-token record resolutions (acting user, origin offering, origin clazz) fail closed as `401 forwarded_token_invalid`, using `find_by`/rescue rather than bang `find` (which would surface as 404) and never letting a nil `clazz` raise a 500. The `class_hash` claim is only a fail-closed cross-check.

### `store? => false` and `devise.skip_trackable`
**Decision**: The rewritten strategy declares `store? => false` (no session serialization of the per-request student) and additionally sets `devise.skip_trackable` on the forwarded path (session-store suppression does not stop the separate trackable hook), so acting-as-student never corrupts the real student's sign-in tracking. The mapped-user path keeps today's harmless behavior.

### `capability?` nil-guard
**Decision**: `capability?` and the membership validation nil-guard the serialized column (`(capabilities || [])`), mirroring the `enabled_bookmark_types ||= []` precedent, so an unset/`nil` capabilities set is treated as empty and never raises.

### Origin class resolved by a single canonical anchor
**Decision**: `offering_id -> offering.clazz` is the one origin-class derivation used by both lock and enroll; `class_hash` is only a fail-closed cross-check (mismatch → `forwarded_token_invalid`), never a `find_by_class_hash` lookup. `OidcAuthContext` exposes resolved `#origin_offering` / `#origin_clazz` so both operations anchor to the same object.

### Opt-in gate keys on `capabilities.present? || requires_forwarded_jwt?`
**Decision**: The two fields are orthogonal (`requires_forwarded_jwt` is an identity choice; `capabilities` are extra lifecycle powers), so the gate keys on either. This makes a Phase-2 header-absent call return the correct `401 forwarded_token_required` and makes `success!(nil)` unreachable. No model validation forbids `requires_forwarded_jwt=true` + empty capabilities (a legitimate future config).

### Auth-error rendering mechanism = controller-level detect-and-render
**Decision**: Not strategy `fail!` + `CustomFailure`. Verified that a strategy `fail!` never reaches `CustomFailure` under this app's lazy `current_user`. The strategy stamps `portal.auth_error` and fails non-bang; the `ForwardedAuthGuard` concern renders `401 + error_code`. Fail-closed is enforced by the guard keying on the stamp, not by halting the chain.

### Forwarded-token verification lives in a dedicated PORO
**Decision**: `ForwardedFirebaseToken` (in `lib/`) runs every fail-closed check and returns `{user, origin_offering, origin_clazz}` or raises `Invalid` with a reason symbol, keeping the strategy thin and the checks unit-testable off the request path. Origin objects are resolved and validated once, at auth time.

### Client resolved downstream by stable id
**Decision**: The strategy stamps `portal.auth_client_id`; downstream resolution keys on the id, never on `portal.auth_client` (name, which has no uniqueness validation). The name stays display/logging-only.

### Capability grant as rake tasks vs a data migration
**Context**: The one client's `sub` is environment-specific and the record is created by hand via admin CRUD.
**Options considered**:
- A) Rake tasks: explicit, env-parameterized, re-runnable, atomic Phase-2 flip.
- B) A Phase-1 data migration keyed on an ENV sub: couples a data change to the schema deploy, still leaves Phase-2 as a task.
- C) Admin UI only: not scriptable/repeatable; the Phase-2 flip by hand is error-prone.

**Decision**: **A** (rake tasks): `oidc:grant_forwarded_capabilities`, `oidc:verify_forwarded_capabilities`, and the Phase-2 `oidc:require_forwarded_jwt`. The grant is release-critical and must run and be verified before REPORT-83 forwarding is enabled (an un-granted client silently keeps authenticating as the over-privileged mapped admin). The admin form remains a manual fallback.

### Scope of ForwardedAuthGuard on oidc_send
**Context**: `oidc_send` (replaced by RIGSE-353's `teacher_send`) is left unchanged by this story.
**Options considered**:
- A) Include the guard on `oidc_send` too: uniform contract, no test breakage, but modifies an out-of-scope endpoint with no remaining consumer.
- B) Defer: guard only the two endpoints RIGSE-352 owns; RIGSE-353 adds the reusable concern to `teacher_send`.

**Decision**: **B** (defer). The guard is included on `offerings#update_student_metadata` and `students#add_to_class` only.

### Forwarded-student requests could take the privileged teacher/admin branch (External Review, HIGH)
**Decision**: Both action-scoped queries dispatch to the forwarded branch **exclusively** when `acting_as_forwarded_user?` (`return forwarded_… if …; else the teacher/admin predicate`), never OR-ing the two, so a forwarded token minted for a user who is also a class teacher / admin / project-admin cannot bypass the student-scoped guards. `target_is_acting_student?` binds the enrolled student on both `user_id` and `student_id`.

### `target_is_acting_student?` must require every provided identifier (Security self-review, HIGH)
**Decision**: An any-match check (`user_id` OR `student_id`) is a bypass, because `find_student_from_params` prioritizes `student_id`: a token for A could send `user_id=A` + `student_id=B` and enroll B. The check requires **every** provided identifier to resolve to the acting student (and at least one present).

### "pipeline" terminology purged
**Decision**: "pipeline" is report-service's own job terminology, so portal-side coinage uses the `forwarded` prefix (`forwarded_update_offering_state?`, `forwarded_enroll_student?`, `reject_forwarded_auth_error`, `oidc:grant_forwarded_capabilities`, etc.). The spec title/folder use "Forwarded-Student Portal Auth".

## Future Extension: non-student forwarded identities (teacher/other) — DEFERRED, NOT PLANNED

RIGSE-352 gates the forwarded path to **learner** tokens at the auth layer (`ForwardedFirebaseToken` requires `claims.user_type == "learner"` and a resolved `portal_student`). A teacher/other forwarded-identity flow was investigated as a possible extension and **deliberately deferred**: it is **not** a small relaxation of the learner gate, and there is no concrete non-student operation to drive it. This section records the code-verified findings from that investigation so a future story starts from them rather than rediscovering (or, worse, shipping an unsafe global version). The naive approach — "accept any Firebase token and check for a student at the usage sites" — is unsafe; the reasons are below.

### Why it is not a small change

**The forwarded override is global to the opted-in client's request, not per-endpoint.** `authenticate_forwarded_student!` calls `success!(result.user)`, and the OIDC strategy's `valid?` is **not path-scoped** (it claims any Google-issuer `Bearer` token on any endpoint), so the forwarded identity becomes `current_user` on **every** authenticated endpoint that client can reach, including ones with no forwarded-student policy branch (`emails#oidc_send`, and ordinary reads/writes such as `offerings#index/show`, `classes#mine/show`, rosters, reports). This was safe for RIGSE-352 only because a **learner is low-privilege** — the blast radius is the student's own data, which report-service is meant to read anyway.

**A teacher is high-privilege, so the same global override is unsafe.** Dozens of API actions authorize on plain `teacher?` / `class_teacher_or_admin?` / `api_index?` and never consult `acting_as_forwarded_user?`. A forwarded teacher `current_user` would therefore pass all of them with that teacher's **full authority across every class they own**, not just the study's origin class. Merely forwarding a teacher token would let report-service read/act as the teacher everywhere — the exact over-privilege model F removed, reintroduced for a higher-privilege identity. A per-operation "require `user_type == teacher`" assertion on the two lifecycle branches does **not** fix this, because the leak is on the *other* endpoints, which have no such branch.

### Verified facts (from `jwt_controller.rb` and its specs)

- The portal's `firebase` endpoint mints exactly four forwardable shapes: `learner`, `teacher`, `researcher`, and a generic `user`. Nothing else can be forwarded.
- **Teacher token** (empirically verified, `jwt_controller_spec.rb:240-289`): `user_type: "teacher"` + `platform_user_id` + an **optional** `class_hash` (present only when minted with a `resource_link_id`/`class_hash` param) + **no** `offering_id` (omitted by design, so a teacher token is not restricted to one offering). So a teacher token carries, at most, a class-level anchor — never the offering-level anchor the learner authorization model is built on.

### What a real teacher extension would require (not built)

1. **Per-endpoint activation for high-privilege forwarded identities.** The teacher override must be honored **only** on endpoints that explicitly opt in (extending the `ForwardedAuthGuard` seam); everywhere else an OIDC request carrying a forwarded teacher token must **not** become the teacher (fall back to the mapped user or fail closed). This is what makes "fail closed for any identity type no operation asserts" actually true for a high-priv identity, and it is a genuine architectural addition beyond RIGSE-352 (the override decision moves from the global strategy to a two-step: the strategy stamps a *candidate* forwarded identity + type; an opted-in action promotes it to `current_user`). The low-priv learner path may stay globally activated as today.
2. **A `class_hash → origin_clazz` least-privilege anchor** for teacher tokens (via `Portal::Clazz.find_by_class_hash`, the one sanctioned use of that finder for a forwarded token, since teacher tokens have no `offering_id`), so a teacher operation can be scoped to the study's origin class rather than all of the teacher's classes. This anchor is a scoping signal, **additive to** and never a replacement for the normal teacher-of-class authorization; both apply. Fail-closed layering: a present-but-unresolvable `class_hash` is `401 forwarded_token_invalid`; an absent `class_hash` yields a valid identity-only teacher token that a class-anchored operation denies (`403`) at its call site. Cross-repo: report-service must mint the teacher token with `resource_link_id`/`class_hash` to obtain the anchor.
3. **`user_type` recorded on the context, asserted per operation.** `OidcAuthContext` would carry `#forwarded_user_type` and the origin `#origin_clazz` (offering-derived for learners, `class_hash`-derived for teachers); each operation branch asserts its required type + capability. To avoid per-callsite boilerplate this should live in shared `OidcAuthContext` helpers (e.g. `#acting_as?(user_type)`, `#authorized_for?(user_type, capability)`) driven by a single `user_type -> required role` registry, and the RIGSE-352 branches would be refactored onto them.
4. **A concrete non-student operation and capability** to drive and test any of the above. Without one, the mechanism authorizes nothing and is untestable.

### Recommendation for when this is revisited

Do this only when a specific teacher (or other) operation is actually needed. Scope it to **teacher** first (exclude `researcher`/`user` until requested, to keep the endpoint-activation surface minimal), lead with item 1 (per-endpoint activation) since it is the load-bearing safety property, and treat items 2–4 as the per-operation work that its driving story owns. The shipped learner-only, globally-activated gate remains correct and is a clean subset of this design.
