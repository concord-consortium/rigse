# RIGSE-352: OIDC-Minted Scoped Portal Tokens

**Jira**: https://concord-consortium.atlassian.net/browse/RIGSE-352 (epic: DT-20)
**Repo**: https://github.com/concord-consortium/rigse
**Implementation Spec**: [implementation.md](implementation.md)
**Status**: **In Development**

> **Supersedes** the forwarded-student design in `specs/RIGSE-352-forwarded-student-portal-auth.md`
> and the separate OIDC-forwarded `oidc_teacher_send` endpoint from the RIGSE-353 spec. Both are
> historical once this lands; do not reconcile the two 352 designs.
>
> This design was settled over several rounds of security review; its decisions and resolved questions
> are labeled `D1-D11` and `Q1-Q4` and are referenced by those labels throughout this spec and
> [implementation.md](implementation.md).
>
> **Note on the Jira title:** the RIGSE-352 story is still titled "Pipeline portal auth: act as the
> forwarded student", which describes the abandoned design. Renaming it is a follow-up (see "Affected
> artifacts").

## Overview

The report-service "I'm Done!" pipeline needs to act on the portal (enroll the student into an assigned
class, lock the pre-test offering, notify the teacher) on behalf of the student who clicked. Instead of
teaching every portal endpoint a new forwarded-student identity and a per-feature capability (the
current 352 branch), the firebase function exchanges the student's forwarded Firebase token for a
**scoped portal JWT** at a single minting endpoint, then makes ordinary portal API calls with that
portal token. All the elevation logic lives in one place; every downstream endpoint stays as it is
today, except one small new teacher-notification email endpoint.

## Project Owner Overview

The fall AI4VS RCT spans roughly two dozen classes across five or more real teachers, so the pipeline
can no longer rely on a single hardcoded service account being a co-teacher of every study class. This
work generalizes what the spring pilot already does (the OIDC client's mapped user simply *is* the
teacher of the study classes) so it scales: the pipeline derives the acting teacher per-class from the
student's class, rather than hardcoding one teacher. The result is reusable pipeline infrastructure: a
new pipeline for any project or PI needs zero portal changes, because it mints the identity it needs and
calls existing portal endpoints. The design concentrates all elevation at one auditable choke point (the
mint) and leans on an audit trail rather than per-feature policy branches.

## Background

### Why the pivot (from the current 352 branch)

The current branch sets `current_user = student` via a Devise bearer-strategy override, adds a
per-capability model (`enroll_student`, `update_offering_state`, `send_teacher_email`, ...), and adds a
forwarded-student branch to each affected policy (`forwarded_enroll_student?`,
`forwarded_update_offering_state?`). Two problems drove the redesign (from PR review + follow-up):

1. **Per-feature capabilities force a portal deploy per script feature**, which defeats the reason the
   scripts live outside the portal (rapid prototyping). Each new automation would need a new capability
   and a new portal release.
2. **It spreads new permission-branch logic** across policies that has to be reasoned about
   independently, and it uses the Firebase token as the acting identity across many endpoints when that
   token is really Google's, not the portal's.

The mint model answers both: one endpoint, one boolean flag, and the Firebase token is consumed at
exactly one place (the mint) rather than forwarded into every call. Downstream calls act as a real
portal teacher, so existing teacher authorization applies with no new policy branches.

**This generalizes what spring already does, rather than inventing a new trust model.** In the spring
pilot the OIDC client's mapped user simply **is** the teacher of the study classes. That is why the
current pipeline works end to end with no special policy: `oidc_send` reaches the teacher because
`current_user` *is* the teacher, and `update_student_metadata` / `add_to_class` pass
`class_teacher_or_admin?` / `update_roster?` for the same reason. The pipeline has therefore always
acted as a teacher. The mint model keeps exactly that identity model and only stops **hardcoding which
teacher**, deriving it from the student's class instead.

That distinction is what the fall RCT forces. Fall spans 8 origin classes (`FT-2026-<Teacher>` x5,
`FL-2026-Section<N>` x3) plus their `-Gator`/`-Shark` subclasses, so roughly two dozen classes across
five or more real teachers. The single-mapped-user hack only holds if that one account is a co-teacher
on every one of them. Deriving the teacher per-class is what makes it scale.

### Design goal: reusable pipeline infrastructure, not RCT plumbing

The point of the jobs/pipeline system is to make **ad-hoc pipelines easy to stand up** for any project
or PI. This story is the portal-side half of that, written as generic infrastructure rather than
fall-RCT-specific code:

- **A new pipeline should need zero portal changes.** It mints the identity it needs and calls existing
  portal endpoints. No new capability, no new policy branch, no portal release.
- **The OIDC client's mapped user must become irrelevant.** Today it works only because that account
  happens to be the teacher of the study classes. Another PI's pipeline will have a different teacher,
  or none. Once the identity comes from the mint, the mapped user can be a neutral service account and
  the same client serves every project (see "Rollout and end state").
- **The teacher-email endpoint is a generic primitive.** It takes `subject` and `message` from the
  caller; the portal only guarantees "these recipients are the teachers of a class you teach". Nothing
  about the AI4VS message format belongs in the portal.
- **`learner` minting exists for this reason**, not merely as a future affordance: the fall pipeline does
  not need it, but a different PI's pipeline may need to act as the student, and it should not have to
  reopen the mint design to do so.

### Architecture

Current task architecture with the proposed `(NEW behavior)` step:

```
button interactive (question-interactives)        auth-agnostic, emits createJob({task,...})
        │  postMessage
        ▼
Activity Player host (firebase-job-executor.ts)   holds student rawPortalJWT; exchanges it at the
        │  Authorization: Bearer <firebase JWT>   portal for a Firebase JWT today; POSTs to submitTask
        ▼
report-service submitTask / taskWorker            forwards the Firebase JWT through the Cloud Tasks
        │  { data: { jobPath, firebaseJwt } }     payload (survives the queue delay), unverified
        ▼
report-service pipeline step (NEW behavior)       per scope: POST /api/v1/jwt/oidc_mint with the OIDC
        │  OIDC + firebase_token + description    service token, the forwarded Firebase token, and a
        │                                         short description label for the audit log; returns
        │  ◄── scoped portal JWT ──               a scoped portal JWT (learner or teacher)
        ▼
report-service step uses the portal JWT           normal portal auth (jwt_bearer_token). Enroll
        against portal endpoints                  and offering-state reuse EXISTING endpoints; teacher
                                                  notification uses the ONE new endpoint below.
```

The portal is the verifier for both inputs: it verifies the OIDC service token (existing Google OIDC
verifier) and the Firebase token (`SignedJwt.decode_firebase_token_by_iss` / `ForwardedFirebaseToken.verify`).
The firebase function verifies nothing; it forwards.

**Why the forwarded student token is a Firebase token and not a portal token.** Firebase is load-bearing
on both ends of this flow:

- **The pipeline steps themselves need it.** `evaluate-completion` and `random-assignment` read the
  student's answers straight out of Firestore via `getClientFirestore(firebaseJwt)`. Those reads go
  through Firestore security rules, which authorize on `request.auth.token.*` and require a genuine
  Firebase Auth session scoped to that student. A portal JWT cannot authenticate to Firestore at all.
- **The Activity Player needs it too.** The real-time job-status subscription (`onSnapshot` in
  `firebase-job-executor`) and student-work reads are gated by the same rules; the AP establishes the
  session with `signInWithCustomToken` using the Firebase token.

Since a Firebase token has to exist and be forwarded regardless, reusing that same token as the mint
input costs nothing. The portal can verify it directly (Google's Firebase JWKS via
`SignedJwt.decode_firebase_token_by_iss`), so nothing is lost by accepting it at the mint. The token the
portal *mints and returns* is a normal portal JWT used for the portal calls.

**What each pipeline step needs — today's spring pipeline** (verified against `functions/src/tasks/ai4vs-flvs/`,
the `"spring-2026"` entry in `PIPELINES`):

| Step | Portal call | Identity needed |
|---|---|---|
| `evaluate-completion` | none | Firebase token only (Firestore reads) |
| `random-assignment` | `POST /api/v1/students/add_to_class` | **teacher** of the assigned target class |
| `lock-activity` | `PUT .../update_student_metadata` | **teacher** (`:update?` = `class_teacher_or_admin?`) |
| `send-email` | the new teacher-email endpoint | **teacher** (`class_teacher?`) |

**What the fall pipeline will need** (step composition from epic stories P1/P2/P3/P5; the **authorization**
column is verified against current portal code):

| Step | Portal call | Identity needed |
|---|---|---|
| `evaluate-completion` (unchanged) | none | Firebase token only |
| origin-class-word resolve (P1/O14) | `GET /api/v1/offerings/:id` | **teacher** (`api_show?` includes `class_teacher_or_admin?`); one call given the `class_word` serializer field |
| target-class resolve (P1 helper) | `GET /api/v1/classes/info?class_word=` | **none enforced** — `classes#info` has no `authorize` call |
| `random-assignment` (P3) | none for the compute | Firebase token only (Firestore answer reads) |
| enroll (P1/P3) | `POST /api/v1/students/add_to_class` | **teacher** of the target class (mint with `class_id`); also passes `authorize student, :show?` |
| `set-offering-state` (P2) | `PUT .../update_student_metadata`, **invoked several times** (lock current, hide current, open target) | **teacher** of the class owning each offering |
| `send-email` | `POST /api/v1/emails/send_class_teachers` | **teacher** (`class_teacher?`) |

Two consequences:

- **`classes#info` requires no class membership**, so resolving a class *word* to an id does not require
  already teaching that class. That removes a circularity: you need the target `class_id` to mint a
  target-scoped teacher token, but you only know the class *word*.
- **A stage run needs one or two mints, not one per step.** An origin-class mint covers the reads, the
  lock of the current offering, and the email; a `class_id`-scoped mint covers anything acting on the
  target class. Mint with `class_id` whenever acting on the target, because the origin-class mint picks a
  teacher deterministically (Q2) who may not teach the target.

In every portal call across both tables the **student is a parameter, not the actor** (`user_id`,
`clazz_id`), so both pipelines only ever need `teacher` tokens. `learner` minting is kept for other
projects' pipelines, not for these; do not wire it up by accident.

**Mint during the run, not once at pipeline start.** `random-assignment` does not know which class to
enroll into until mid-step (it computes treatment vs control from the answers), so a single mint at
pipeline start cannot request the right `class_id`. In practice that is one or two mints per stage run,
not one per step: a token may be reused across steps that act on the same class.

**Minting a teacher token for a class other than the learner's own.** The enroll step acts on the
assigned Gator/Shark class, which is not the class the learner's Firebase token is bound to. So the mint
accepts a target `class_id` and issues a teacher token for that other class when the two classes share a
teacher — a non-empty intersection of the two teacher sets
(`(origin_clazz.teachers.to_a & target_clazz.teachers.to_a).any?`). The token is minted for the
least-privileged teacher (Q2) drawn from that intersection so the downstream roster call authorizes
normally under existing teacher policy. If no teacher is common to both classes, the mint fails closed
and issues nothing.

## Requirements

### Mint endpoint

- Add a portal **mint endpoint** (`POST /api/v1/jwt/oidc_mint`) that:
  - Authenticates the caller via the existing OIDC bearer path (Google OIDC service token), and requires
    the OIDC client to have minting enabled via a single **boolean column** on `admin_oidc_clients`
    (`can_mint_scoped_tokens`, `default: false, null: false`). No capability list, no serialized array:
    one gate, fail-closed by default so no existing client gains minting implicitly.
  - Requires a forwarded **Firebase student token** as a request param, and verifies it server-side.
  - Mints and returns a **scoped portal JWT** whose subject is derived only from the verified Firebase
    token (never from a caller-supplied user id).
- The mint may issue **only** `learner` or `teacher` scoped tokens. **No `user`/admin token minting.**
  - `learner`: the exact student named in the Firebase token (own identity; no escalation). Currently
    unused by the `ai4vs-flvs` pipeline; kept for generic reuse. Do not wire it into the fall pipeline by
    accident.
  - `teacher`: the **least-privileged** teacher of the class the Firebase token is bound to (Q2), a
    bounded escalation to that class's teacher.
- The mint is called **per scope, cached for the duration of a run** — not once up front, not blindly per
  step. A "scope" is the identity being assumed: the origin class's teacher, or a specific target
  class's teacher. A teacher token is not class-scoped (D3) and so is reusable across steps acting on
  that same teacher's classes.
- The mint accepts an optional **`description`** audit label (a short string combining pipeline and step,
  e.g. `ai4vs-flvs/random-assignment`). It is **log-only**: it must never influence what is minted or any
  authorization decision, and must be sanitized before logging (D7).
- **Cross-class teacher mint** (for enroll-into-assigned-class): the mint accepts an optional target
  `class_id`. It issues a teacher token for the target class **only if** the target class shares a
  teacher (or co-teacher) with the Firebase token's origin class, and mints the least-privileged shared
  teacher's token (Q2). Same shared-teacher rule the current branch encodes at `clazz_policy.rb:95`,
  moved to mint time.
- The minted token carries an **audit claim** identifying it as OIDC-minted (minting OIDC client id +
  origin offering/class), so downstream calls made with it are attributable to a script rather than to
  the teacher personally.
- Elevation authority comes from the **verified Firebase token + the `can_mint_scoped_tokens` flag**,
  never from the OIDC client's mapped user being privileged. The arbitrary-minting bypass is closed **in
  code** by denying the `oidc_bearer_token` strategy on `jwt_controller`'s existing actions (see D1).

### Teacher selection (Q2)

- From the eligible teacher set, prefer a teacher with **no elevated roles**; among those, pick the
  lowest `id` for a stable, reproducible choice. The eligible set is the origin class's teachers for an
  origin-class mint, or the shared-teacher intersection for a cross-class mint.
- "Elevated" means any role that widens authority beyond a plain teacher: the global `admin` / `manager`
  / `researcher` roles (`User#has_role?`), or project-level `is_project_admin?` / `is_project_researcher?`.
- **The mint does *not* refuse to mint for an elevated teacher.** When every eligible teacher is elevated,
  the mint still succeeds for the least-privileged (lowest-id) one — some classes legitimately have only
  an elevated teacher (Trudi is the sole teacher of a subset of the fall FLVS sections). See Q2 for the
  full rationale (refusing would be a support nightmare).

### Downstream usage

- Enroll and offering-state steps use the returned token against **existing, unchanged** portal endpoints
  (roster / `update_student_metadata`). No new per-feature endpoints, no policy branches.
- Add **one** new endpoint: a **teacher-notification email endpoint**
  (`POST /api/v1/emails/send_class_teachers`), authenticated by a portal **teacher** token (the minted
  teacher token via the `jwt_bearer_token` strategy, NOT OIDC):
  - Accepts `subject`, `message`, and a **required** `class_id`. Sends to **all** non-blank teacher
    emails of that class in one message. There is no "email just me" mode (Q1b).
  - **Authorization is the acting teacher's own identity:** allowed only if `current_user` is a teacher
    of the passed class (Pundit `class_teacher?`). A caller can never email a class they do not teach, and
    never supplies a raw recipient address. A minted **learner** token is denied.
  - A request with no `class_id` is rejected; there is no fallback recipient.
  - Reuse `oidc_send`'s input hygiene: require string `subject`/`message`; strip CR/LF from `subject`.
  - Distinct failure codes, sending nothing in every case: missing `class_id` → `400`; unresolvable
    `class_id` → `400` ("The requested class was not found"); caller not a teacher of the class → `403`;
    class with no non-blank teacher email → `422`; delivery failure → `502`. The nil check must precede
    `authorize` (passing nil to Pundit raises an unrescued `Pundit::NotDefinedError` → 500). Guard
    nil-user teachers: `class.teachers.map { |t| t.user&.email }.reject(&:blank?)`.
- Keep master's OIDC client model/table, the OIDC bearer strategy (mapped-user form), and
  `emails_controller#oidc_send` unchanged; the only model change is the one new boolean column. The new
  teacher-email action must NOT inherit `emails_controller`'s `require_oidc_auth!` (it is portal-token
  authed), so the guard is skipped for that action only.

## Security decisions

These are load-bearing and carried verbatim from the reviewed design. Two (D4, D8) were withdrawn after
review showed them to be illusory controls; they are kept as records so they are not re-proposed.

### D1 — Do not require the OIDC caller to be a site admin

The existing `jwt_controller` already mints for an arbitrary `target_user_id` when `can_access_user` is
true, and `can_access_user` returns true for any admin (`jwt_controller.rb:37`). If the mint OIDC client
mapped to a site admin, it could mint tokens for **any** student via that existing path, with no Firebase
token, bypassing the whole constraint. Therefore: the mint runs on a **dedicated action** that never
falls through to `can_access_user`, gated by `can_mint_scoped_tokens` on a **non-privileged** service
user. The Firebase token supplies the constrained subject; the flag supplies the authority.

**Close the bypass in code, not by configuring the mapped user.** The client is keyed on the Google OIDC
`sub` (`Admin::OidcClient.find_by(sub:)`, `sub` unique) and the firebase functions authenticate with a
single service account, so there is exactly **one** client row; a roleless second client is impossible.
That single client's mapped user must stay privileged while the spring pipeline still calls portal
endpoints directly. So instead: **deny the `oidc_bearer_token` strategy on `jwt_controller`'s existing
actions** (`portal`, `firebase`). Verified safe: report-service makes no calls to `/api/v1/jwt`, and the
AP reaches those actions with a portal JWT or a session, never with an OIDC token. With that guard, D1
holds **regardless of the mapped user's roles**, and survives someone later granting that account admin.

The privileged mapped user is transitional; neutralizing it is a goal (see Rollout), but D1 does not
depend on it happening — the code guard already holds.

### D2 — Bounded escalation, stated precisely

The bound is on **which identity may be assumed**, not on what that identity can do. The only subjects
issuable are "the student named in the Firebase token" or "a teacher of that student's class" (or a
shared teacher of an assigned class). No other subject is selectable, and there is no `user`/admin token
type.

**A minted token carries whatever authority its subject already has.** If the teacher of the class is
also a project admin or site admin, the minted token is admin-capable, because portal authorization
reads **DB roles** off the reloaded `User`, not anything in the JWT. This is inherent to assuming an
identity, and is exactly what that teacher already gets from a normal session or the existing
`jwt_controller#portal` endpoint. **The mint manufactures no authority; it assumes an identity.** This is
a live case: the study teacher is also a project admin, which widens `update_roster?` and
`StudentPolicy#show?` to that project.

Do not read D2 as "the resulting token is never admin-capable" — it is not that, and no claim-level trick
can make it so. The compensating control is **auditability (D5)**, not restriction: the
`minted_via_oidc_client_id` and `minted_for` claims are what distinguish "the teacher did this" from "a
script acted as the teacher".

**Refinement (Q2): prefer the least-privileged eligible teacher.** When a class has several co-teachers
the mint picks one with no elevated roles if any exists, falling back to an elevated teacher only when
every eligible teacher is elevated (minting still succeeds — see Q2). This narrows the common-case blast
radius without changing the model: it is a subject-**selection** preference, not an authorization
restriction, so the compensating control remains D5's audit trail. A minted token can still be
admin-capable whenever the chosen teacher genuinely is elevated.

### D3 — Minted teacher token is NOT class-scoped at the auth layer (accepted)

A minted teacher token, used through the normal `jwt_bearer_token` path, makes `current_user` that
teacher, and existing teacher policies (`ClazzPolicy#class_teacher?` = `record.is_teacher?(user)`, and the
`OfferingPolicy#class_teacher?` = `record.clazz.is_teacher?(user)` form used for offering records) grant
access to **all** of that teacher's classes, not just the origin one. Accepted under the "one maintainer owns
the whole chain + D9" model. True per-class scoping would require a class claim plus a check in the
teacher policies (a portal change); out of scope for v1. Residual risk is bounded by the standard token
lifetime and by **D9** (a minted token cannot be re-minted into a fresh or unmarked JWT). It is **not**
bounded by non-persistence while **D10's known gap** stands.

**Accepted delta: the `open_only_write?` restriction is not preserved.** The current 352 branch let a
non-origin offering only ever be unlocked or unhidden, never locked or hidden, because `current_user` was
the *student*. Under the mint model there is no equivalent: `update_student_metadata` authorizes
`offering, :update?` = `class_teacher_or_admin?`, which a minted teacher satisfies for every offering in
every class that teacher teaches. Accepted deliberately: a teacher legitimately may lock and hide their
own classes' offerings, and P2 requires lock-current, hide-current **and** open-target, so a blanket
open-only rule would block the fall design.

**What the acceptance rests on, and when to revisit.** Today a single maintainer writes the pipeline code
*and* the portal code, performs the rollout, and makes the admin change that enables minting. Two
structural gates back that up — pipeline code ships as reviewed code in a repo that maintainer owns, and
`can_mint_scoped_tokens` defaults to `false`. **Revisit class-scoping** when either gate weakens: (a)
minting is enabled for an OIDC client outside CC's operational control, or (b) pipeline code becomes
deployable by someone who does not also own the portal side.

One nuance: the **author** surface is already runtime, not review-gated (a curriculum author picks the
button's `task`/`taskParams` in authored state). That does not breach the bound, because whatever task
runs can still only act as a teacher of the *clicking student's own class* — but the bound, rather than
code review, is what contains that surface. If scoping is ever added, the lost `open_only_write?`
restriction is the natural first thing to reinstate.

### D4 — WITHDRAWN (short-TTL): standard TTL for the minted token

An earlier draft gave minted tokens a deliberately short expiry. **Dropped**, because it never bound
anything: the Firebase input token lives `3600`s and rides the Cloud Tasks payload, so anyone holding it
(plus the OIDC client) can mint fresh tokens for as long as *it* lives. Making the output shorter than
the input is theater and adds a failure mode (a token expiring mid-run). Minted tokens use the same
standard TTL as any other portal token; the shared claims builder needs **no** TTL parameter. Bounding a
leaked minted token is instead handled by **D9 (no re-minting)** plus the rule that the token is never
logged.

**The input token's lifetime versus queue age — expiry is a terminal failure.** The Firebase token is
captured at `submitTask` and used when the worker runs, so it must survive the Cloud Tasks delay
including retries. Re-minting it at execution time is **not available** (the student is gone,
`jwt_controller#firebase` is denied to OIDC callers by D1, and the mint cannot bootstrap itself). So an
expired input is **terminal**; the recovery that works is the student clicking the button again.
Requirements that follow:

- **The portal must make expiry distinguishable.** The mint must not collapse every
  `ForwardedFirebaseToken::Invalid` into one failure; the expired case needs its own error code
  (`:expired`, distinct from `:signature`, `:not_learner`, etc.) so report-service can separate
  "terminal, tell the student to re-click" from "transient, retry".
- **report-service must fail terminally, not throw** (sibling-repo concern): steps must return
  `{ success: false, message }` so `markComplete(..., "failure")` runs and the message reaches the
  student. Bound the Cloud Tasks retry window below the token lifetime. Idempotency matters more here
  because a re-click re-runs the pipeline.

### D5 — Auditability via a token claim, not just mint logging

Log the mint call, AND stamp a claim on the minted token so the `jwt_bearer_token` request-auth logging
can record that downstream calls were made by a script-minted token. The claim carries the caller's
`description` label too, giving a full trace: mint log → token claim → downstream request log.

### D6 — The teacher-email endpoint is gated by the acting teacher's identity

Recipients are always **all teachers of the passed class**, and the class is authorized by
`class_teacher?`. There is no self-send fallback (Q1b), so there is exactly one recipient rule and no
request field ever names a recipient. A learner token cannot use it.

### D7 — The `description` audit label is untrusted, log-only input

Caller-supplied free text; never read as an authorization input or used to select what is minted.
Sanitize before logging or embedding: cap length and strip CR/LF (reuse
`oidc_bearer_token_authenticatable.rb#sanitize_log`, `value.to_s[0, 100].gsub(/[\r\n]/, ' ')`), so a
caller cannot forge log lines. Optional: a missing label logs as `(none)` rather than failing the mint.

### D8 — WITHDRAWN (2026-07-24): minted tokens carry the subject's normal claims

An earlier draft required suppressing `add_admin_claims` and stamping `admin: -1` / `project_admins: []`.
**Withdrawn.** (1) It does not restrict anything — portal authorization reads **DB roles**, not JWT
claims, so an admin teacher's token stays admin-capable. (2) It would make the token lie about its
subject to downstream consumers (Firebase rules, report-service, other CC apps), a gratuitous divergence
from what `jwt_controller#portal` already emits. So the mint uses **normal claim building**, unchanged;
the shared builder needs no `admin_claims` parameter. If we ever need to constrain a minted token, the
lever is **scoping** (D3's revisit trigger), never claim suppression.

### D9 — The audit marker must survive every token derivation

Two mechanisms, deliberately different in kind.

**Why this matters:** D2 accepts that minted tokens carry full teacher authority and names auditability
as the compensating control. A path that yields an *unmarked* token defeats that control and allows
indefinite refresh.

**`jwt_controller#portal` is NOT the only place portal tokens are issued.** On `master` there are
**five** `create_portal_token` call sites:

| Site | Subject | Gate |
|---|---|---|
| `jwt_controller.rb:219` (`portal`) | the token subject | denied below |
| `home_controller.rb:173` (`authoring_site_redirect`) | **`current_user`** | `HomePolicy#authoring_site_redirect?` (teacher-ish) |
| `classes_controller.rb:82` (`log_links`) | **`current_user`** | `ClazzPolicy#log_links?` (admin-ish) |
| `external_activity.rb:156` | a named learner | server-side flow |
| `create_collaboration.rb:81` | a named learner | server-side flow |

`authoring_site_redirect` was a real laundering hole (any route accepts `Authorization: Bearer <portal
JWT>` because the strategy is on `User` globally; a minted teacher passes its policy; the action puts a
fresh `create_portal_token(current_user, ...)` into a 302 `Location`). `log_links` is the same shape for
the admin-teacher case.

**Mechanism 1 — propagate at the choke point.** All five sites go through
`SignedJwt.create_portal_token`, so the marker is propagated there via a request-scoped `Current`
(`ActiveSupport::CurrentAttributes`), set in **both** decode paths (the Warden strategy and
`api_controller#check_for_auth_token`) and read when signing. With propagation, `authoring_site_redirect`
and `log_links` need no guard of their own: the extracted token still carries the marker.
**Implementation trap:** `create_portal_token` merges with a block that **raises** on duplicate keys, so
propagation must use `||=` semantics (the mint sets the marker explicitly at origin).

**Mechanism 2 — deny outright at `jwt_controller`** (`portal` **and** `firebase`) for any caller whose
token carries the marker. Re-minting there is never legitimate, and it is the one place a caller could
pivot to a **different** user (via `target_user_id`) or obtain a **Firebase** token granting
teacher-scoped Firestore access. The mint endpoint itself needs no such guard (it requires
`oidc_bearer_token`, so a portal token cannot reach it).

Why the choke point rather than a denylist: a sixth `create_portal_token` caller added later inherits
propagation automatically.

**Scope of D9's guarantee — read D10.** Propagation + denial closes **JWT-to-JWT** laundering. It does
**not** close conversion of a marked token into a *non-JWT* credential (D10).

### D10 — KNOWN GAP (accepted, deferred): a marked token can still become a non-JWT credential

Verified, not theoretical. Two paths, both outside the JWT choke point:

1. **Rails session.** `jwt_bearer_token_authenticatable` calls `success!(user)` and defines **no `store?`
   override**, and `config.skip_session_storage = [:http_auth]` covers only HTTP basic auth, so Warden
   serializes the user into the session. One request with a marked token yields a session cookie; every
   request after that is the teacher with **no marker at all**, so `Current` is unset and D9's
   propagation, the `jwt_controller` denial and the D11 rules are all inert. (The rejected branch's OIDC
   strategy explicitly sets `store? → false`; the pre-existing portal-JWT strategy never got the same
   treatment.)
2. **OAuth `AccessGrant`.** `auth_controller#oauth_authorize` triggers `user.access_grants.create(...)`
   (in the `AccessGrant` model at `access_grant.rb:92`, via `AccessGrant.get_authorize_redirect_uri`;
   `ExpireTime = 1.week`) whenever `current_user` is present, later accepted as an opaque bearer token.
   D11 rule 2 guards this at the model's `before_create` regardless of the calling controller.

**Decision: the session fix is deferred to its own story; D9's guarantee is conditional until it lands.**
The `store? false` change alters behavior for **every** portal-JWT consumer (AP, LARA, dashboards) and is
a **pre-existing portal-wide vulnerability** independent of this design (even the 180-second learner
tokens can be traded for a durable session). It deserves its own story, consumer audit and testing.

Consequences to hold honestly while it is open:

- Do **not** describe D9 as making the audit trail unlaunderable. It closes JWT-to-JWT laundering only.
- D3's "never persisted" bound does not hold.
- The D11 rules are **defense in depth, not the primary control**: anyone able to convert to a session
  does not need either. Still worth doing (cheap, and they close the week-long credential specifically).
- **The session fix is a prerequisite for D9's guarantee.** Track it as a blocking dependency.

### D11 — A marked token is valid only within the API namespace, and may never create an `AccessGrant`

Two rules, both fail-closed:

1. **Namespace confinement.** Reject any request carrying `Current.minted_via_oidc_client_id` that is not
   under the API namespace. This denies the Devise identity surface (registrations, passwords,
   confirmations, omniauth linking — a single request could otherwise change the teacher's password and
   take the account over permanently and unmarked), the OAuth authorize/token endpoints, and
   `home#authoring_site_redirect` (killed outright rather than relying on D9 propagation). Chosen over
   enumerating credential routes because it fails closed for routes nobody has written yet. Pipeline work
   lives in the API namespace, so a new pipeline feature still needs no portal change.
2. **`AccessGrant` refusal at the model.** A `before_create` on `AccessGrant` refuses when
   `Current.minted_via_oidc_client_id` is present — the same choke-point shape, covering any caller
   rather than any route. A pipeline never legitimately needs an OAuth grant.

## Technical Notes

- Rails is **8.0.1**, so `ActiveSupport::CurrentAttributes` needs no gem and auto-resets between
  requests.
- There is **no audit infra** in rigse today (no `audited`/`paper_trail`, no audit tables); the marker
  reaches only the ephemeral `Rails.logger` request lines via `auth_log_subscriber.rb`, which reads
  `request.env`. Acting-as-the-real-teacher improves attribution in those existing logs for free; a
  persisted audit trail is out of scope.
- The "lazy Warden" trap recurs in three guards (New work A2, A4): a `before_action` reading
  `request.env`/`Current` must force `current_user` first, or it runs before any strategy has stamped
  and silently no-ops. Treat "force auth, then read the marker" as the standard shape.
- Survivors carried from the current branch (`RIGSE-352-add-oidc-use-override`):
  `SignedJwt.decode_firebase_token_by_iss` + `verify_against_any`, `ForwardedFirebaseToken` (+ specs),
  and the `class_word` `API::V1::Offering` serializer field (REPORT-79 depends on it).
- See [implementation.md](implementation.md) for the full build order, code, and drop list.

## Out of scope

- **report-service** changes: calling `oidc_mint` per scope and switching steps to the returned portal
  token. This spec defines the portal side of the contract only (see the "Downstream contract" section in
  implementation.md, informational).
- **Activity Player / question-interactives** changes: none required.
- Per-class scoping of teacher tokens (D3).
- Replacing the Firebase token with a portal token as the mint input (Firebase is required by Firestore
  rules for the answer reads and the AP subscription; listed so it is not re-proposed).
- **The `store? false` session fix (D10).** Prerequisite for D9's guarantee, but a pre-existing
  portal-wide issue needing its own story and consumer audit.

## Rollout and end state

Portal-side this story is **additive except for two deliberate behavior changes**: the `jwt_controller`
guard (D1/D9) starts rejecting OIDC-authenticated callers on `/api/v1/jwt/portal` and `.../firebase`, and
D11 starts rejecting marked tokens outside the API namespace (inert until Phase 2 enables minting, but a
new filter on every non-API request). No known consumer is affected, but **verify no other OIDC client
depends on those endpoints before deploying**. The existing OIDC mapped-user path is untouched, so the
live spring pipeline keeps working unchanged until report-service migrates.

**One person executes all of this** (both repos, the rollout, the manual admin steps). The two **hard
safety constraints**: Phase 2 must precede any Phase 3 call, and **Phase 5 must follow Phase 4**.

- **Phase 1 — Portal, single deploy** (additive; spring untouched). Build order is dependency-driven; see
  the implementation plan.
- **Phase 2 — Ops: enable minting.** Set `can_mint_scoped_tokens = true` on the existing OIDC client.
  Staging first. Additive and inert (nothing calls the mint yet).
- **Phase 3 — report-service, fall pipeline only.** Portal-JWT fetch sibling, mint helper + per-run
  cache, fall steps on mint-then-call, terminal expired-token handling.
- **Phase 4 — Spring migration** (separate Jira story, after fall is proven). Switch spring's three calls
  to mint-then-call (`oidc_send` → `send_class_teachers` first, then `update_student_metadata` and
  `add_to_class`).
- **Phase 5 — Ops: neutralize the mapped user.** Downgrade the OIDC client's user to a neutral service
  account holding only `can_mint_scoped_tokens`.

**Spring deliberately does not block fall.** As long as the mapped user stays a teacher of the spring
study classes, spring keeps working on the mapped-user path while fall runs on the mint path — same
single OIDC client, concurrently. **Phase 5 cannot move earlier:** a neutral mapped user fails
`class_teacher_or_admin?` / `update_roster?`, so neutralizing before every direct call is migrated breaks
live spring; and the email migration alone is not sufficient (the other two calls depend on the mapped
user's *privileges*, not just its identity).

**End state (after Phase 5):** one OIDC client, keyed on the functions' service-account `sub`, whose
mapped user is neutral and whose only portal authority is minting scoped tokens from a verified Firebase
token. The client is then project-agnostic and a new pipeline reuses it as-is.

## Acceptance criteria

- A mint request with a valid OIDC service token (client with `can_mint_scoped_tokens` true) + a valid
  Firebase learner token returns a portal `learner` token for exactly that student, or a `teacher` token
  for a teacher of that student's class.
- A mint request whose OIDC client has `can_mint_scoped_tokens` false (including a pre-existing client
  that predates the column and defaults to false) is denied.
- A mint request with a missing/invalid/expired Firebase token fails closed and mints nothing.
- An **expired** forwarded Firebase token is reported with its own distinct error code, separable from
  other `ForwardedFirebaseToken::Invalid` reasons, so a caller can treat expiry as terminal and other
  failures as retryable (D4).
- `token_type: user` (or any non learner/teacher scope) is refused.
- A cross-class teacher mint with a `class_id` that shares no teacher with the origin class fails closed;
  one that shares a teacher returns the shared teacher's token.
- For a mint whose eligible teacher set (origin-class teachers, or the cross-class intersection) contains
  **both** a non-elevated teacher and an elevated one (`admin`/`manager`/`researcher`, or
  project-admin/project-researcher), the minted token's subject is a **non-elevated** teacher, chosen by
  lowest id (Q2). When **every** eligible teacher is elevated, the mint still **succeeds** and mints for
  the lowest-id elevated teacher — it does **not** fail closed on elevation.
- The minted token carries the OIDC-minted audit claim, and a portal call made with it is logged as
  script-minted, including the originating step's `description` label.
- A teacher token minted for a teacher who **is** a site admin and/or project admin carries that
  teacher's **normal** claims, identical to what `jwt_controller#portal` emits for the same user (D8
  withdrawn). The minted token is distinguishable from that teacher's own token **only by its audit
  claim** — same TTL, same claims otherwise.
- A minted token presented to `jwt_controller#portal` or `#firebase` is **denied** (D9), so it cannot be
  exchanged for a fresh token, pivoted to a different user via `target_user_id`, or turned into a
  Firebase token. The denial holds even when the request also carries a session (the guard reads
  `Current`, not `request.env`).
- **Any JWT** created while acting under a minted token inherits `minted_via_oidc_client_id` /
  `minted_for` (D9 propagation). Specifically, `classes#log_links` for an admin-teacher yields a token
  that **still carries the marker**. (`home#authoring_site_redirect` is denied outright by D11.) Closes
  **JWT-to-JWT** laundering only — see D10.
- Minting still succeeds when the marker is already set explicitly at origin — propagation must not
  double-add it and trip `create_portal_token`'s duplicate-claim failure.
- A marked token is **rejected outside the API namespace** (D11): Devise registrations / passwords /
  confirmations / omniauth linking, the OAuth authorize and token endpoints, and
  `home#authoring_site_redirect` all deny it. In particular a marked token cannot change the subject
  teacher's password or email.
- A marked token **cannot create an `AccessGrant`** by any route (D11 model-level refusal).
- **Known gap, must not be asserted as passing (D10):** a marked token *can* still establish a Rails
  session, after which no marker exists and every rule above is inert. Write this as a pending/skipped
  test referencing the D10 story rather than omitting it.
- Ordinary downstream calls made with a minted token **actually appear in the logs** carrying
  `minted_via` and `minted_for` — asserted against real log output, not merely against `Current` being
  set (the compensating control D2 depends on).
- `JwtController#portal`'s own claims and TTL are unchanged by the shared-builder refactor.
- A `description` containing CR/LF or exceeding the length cap is sanitized before being logged or
  embedded, and never affects what is minted; an absent `description` still mints successfully and logs
  `(none)`.
- An `oidc_bearer_token`-authenticated request to `jwt_controller#portal` or `#firebase` is **denied**,
  even when the client's mapped user is an admin. Portal-JWT and session callers of those actions are
  unaffected.
- The teacher-email endpoint, called with a minted teacher token and a `class_id` the teacher teaches,
  sends to all non-blank teacher emails of that class; a `class_id` the acting user does not teach is
  denied; a learner token is denied.
- The teacher-email endpoint never reads a recipient address from the request, and a request with no
  `class_id` is rejected rather than falling back to any default recipient.
- The teacher-email endpoint distinguishes its failure modes and sends nothing in every one: missing
  `class_id` → `400`; unresolvable `class_id` → `400`; caller not a teacher of the class → `403`; class
  has no non-blank teacher email → `422`; delivery failure → `502`. An unresolvable `class_id` must
  **not** surface as a `500`.
- Existing `oidc_send`, and all existing enroll/roster/offering-state endpoints, behave unchanged.

## Open Questions

The original design questions are all resolved; recorded here as a decision log. New gaps surfaced during
transcription are marked OPEN at the end.

### RESOLVED: Q1 — Emailing co-teachers

Handled by the `class_id` → all-teachers mode of the new teacher-email endpoint.

### RESOLVED: Q1b — Self-send mode dropped

`class_id` is required; there is no self-send mode. Nothing calls it; it would add a second authorization
path and recipient derivation for zero callers and dilute the endpoint's single reviewable invariant;
"email the authenticated user" is already `oidc_send`'s niche. Cheap to add later if a real caller
appears.

### RESOLVED: Q2 — Teacher selection = least-privileged eligible teacher, tie-broken by lowest id

For a cross-class mint the subject comes from the shared-teacher intersection; for an origin-class mint,
the origin class's teachers. From that eligible set, prefer a teacher with no elevated roles
(`admin`/`manager`/`researcher`, or project-admin/project-researcher); among those, lowest `id` for
reproducibility. **The mint does not refuse an elevated-only class** — it still mints for the
least-privileged (lowest-id) elevated teacher. Rationale (Scott, review round 5): research-class
co-teachers are often the PI or research staff (e.g. Trudi) holding elevated roles; picking such a
teacher when a plain-teacher co-teacher exists needlessly widens the token's blast radius (D2). Refusing
entirely would be a support nightmare (Trudi is the sole teacher of some FLVS sections; the person
testing the button is exactly who we'd block; the "your teacher has too many permissions" message would
recur without anyone remembering why). No "primary teacher" concept exists, so lowest `id` is the stable
tie-break. Supersedes the earlier plain-lowest-id resolution.

### RESOLVED: Q3 — Teacher-email endpoint auth

Portal-token (`jwt_bearer_token`) authed, so `oidc_send` stays untouched and OIDC-only.

### RESOLVED: Q4 — Dedicated mint controller

`API::V1::OidcMintController#create`, routed as `POST /api/v1/jwt/oidc_mint`. Rationale: (a) D1's
containment rests on the mint never reaching `can_access_user`, a private method in `JwtController`; in a
separate class it is not even in scope. (b) `JwtController`'s class-level `rescue_from StandardError,
with: :error_400` would blur the fail-closed reasons. (c) `handle_initial_auth` assumes the *requesting*
user is the subject, the inverse of the mint's model. Common claim-building is shared via a helper (see
implementation "Refactor").

### RESOLVED: Endpoint / column / action working names — keep all three

**Context**: The design uses working names — `oidc_mint` endpoint, `can_mint_scoped_tokens` column,
`send_class_teachers` action. Verified against master's conventions before committing to them.

**Decision**: Keep all three. Each matches an existing convention:
- **`oidc_mint`** sits in the `jwt` namespace beside `portal`/`firebase`; the `oidc_` prefix reads as
  "OIDC-authenticated" by direct analogy to the existing `oidc_send` action (in this codebase `oidc_`
  denotes the auth strategy, not the object), so it correctly reads as "OIDC-authed mint". It is also
  already the cross-repo contract (report-service POSTs `/api/v1/jwt/oidc_mint`).
- **`can_mint_scoped_tokens`** follows the established `can_*` boolean-column precedent
  (`can_add_teachers_to_cohorts`, `can_manage_permission_forms`) and reads naturally as
  `client.can_mint_scoped_tokens?`.
- **`send_class_teachers`** follows the compound snake_case action style; the deliberate *absence* of an
  `oidc_` prefix is correct signalling — unlike `oidc_send` it is portal-teacher-token authed, not OIDC
  (Q3).

**Wiring note (surfaced by this review):** because the mint uses a separate controller
(`API::V1::OidcMintController`, Q4) but lives at `/api/v1/jwt/oidc_mint`, the route must be explicit —
`post 'oidc_mint', to: 'oidc_mint#create'` inside `namespace :jwt` — since a bare `post :oidc_mint` would
map to `JwtController#oidc_mint`.

### RESOLVED: D11 mounted-engine coverage — defer with a tripwire (not A/B/C)

**Context**: The API-namespace confinement (D11 rule 1) is an `ApplicationController` `before_action`,
which mounted Rack engines do not run. The original question was Rack middleware ahead of the router (A)
vs wrapping each engine's route constraint (B) vs both (C).

**Verified before deciding** (code + runtime, on master):
- **Exactly one mount exists:** `Delayed::Web::Engine` at `/delayed_job` (`routes.rb:543`). No other route
  files, no other Rack mounts.
- **It is session-authed and already fail-closed for bearer tokens.** Its constraint is
  `warden.user && warden.user.has_role?("admin")`, and `Warden::Proxy#user` (warden 1.2.9) reads
  `session_serializer.fetch(scope)` only — it never runs strategies. A marked *bearer* token with no
  session gets `warden.user == nil` → 404 before any engine code runs.
- **Nothing decodes the portal JWT ahead of the router.** The middleware stack shows `Warden::Manager` as
  the last auth-relevant middleware; the `jwt_bearer_token` strategy runs lazily *in the controller*, so
  `Current` / `request.env['portal.minted_*']` are set only post-routing and never for a mounted engine.

**Decision: defer coverage, with a tripwire.**
- **Wrapping `/delayed_job` (B) detects nothing** — in both reachable cases the marker is blank: a
  bearer-only marked token never authenticates as the engine, and a marked-token-turned-session is D10, at
  which point the marker is already gone.
- **Rack middleware (A) is the only future-proof option but a poor fit now:** with nothing decoded
  pre-router it would have to force `env['warden'].authenticate(:jwt_bearer_token)` itself, re-triggering
  the strategy's session-storing behavior (entangled with the D10 gap that already makes D11
  defense-in-depth), running on every non-API request — for zero current threat, since there is no
  bearer-authed engine to protect.
- **So:** (1) keep the `ApplicationController` filter for normal non-API routes; (2) do **not** wrap
  `/delayed_job` and do **not** build middleware; (3) add a comment at the `mount` site plus a **guard
  spec** asserting `routes.rb` contains no `mount` beyond the known `Delayed::Web::Engine`, so any future
  mount forces a conscious confinement decision; (4) **trigger to build the middleware (A):** the moment
  any engine authenticating via a bearer/portal token is mounted.

## Affected artifacts and follow-ups

- **RIGSE-352 Jira title/description are stale.** The story still reads "Pipeline portal auth: act as the
  forwarded student". Rename/retitle to the mint design and update the description (or link this spec).
- **Old 352 spec superseded.** `specs/RIGSE-352-forwarded-student-portal-auth.md` (on the old branch) is
  superseded by this spec; mark it so if the old branch is not abandoned.
- **RIGSE-353 spec (another branch, must be updated).**
  `specs/RIGSE-353-oidc-teacher-send-email-endpoint/requirements.md` (branch
  `RIGSE-353-add-email-teacher-endpoint`) describes the OIDC forwarded-student `oidc_teacher_send`
  endpoint, which this design **replaces** with the portal-authed `send_class_teachers`. Its three review
  findings carry over (nil class → 422 rework as 400, no non-blank teacher email → 422, nil-`user`
  teacher guard, delivery failure → 502) and are reflected above. Update/close it on that branch.
- **NEW STORY NEEDED — portal-JWT session storage (D10), blocking D9's guarantee.**
  `jwt_bearer_token_authenticatable` defines no `store?` override and `skip_session_storage` covers only
  `:http_auth`, so any portal JWT establishes a Rails session. Pre-existing portal-wide issue; fix is
  `store? false` on the strategy after a consumer audit (AP, LARA, dashboards). File it and link it as
  blocking D9's guarantee.
- **REPORT-83 (P4) is superseded and needs rewriting in Jira.** It reads "Forward the student's identity
  on the pipeline's portal calls"; every substantive point is now false. It becomes: *call `oidc_mint`
  once per class acted on, then use the returned portal token against existing endpoints*.
- **Cross-repo epic story-breakdown doc needs the same correction.** The shared story-breakdown for the
  "I'm Done!" epic (DT-20), maintained out of band, still describes the abandoned forwarded-student
  architecture: R1, R2, P4, and the dependency-order block are superseded; P1/P2/P3/P5 survive but their
  "acts as the student" notes become "acts as the minted teacher of that class".
