# Delete the CLUE class-token mint

**Jira**: https://concord-consortium.atlassian.net/browse/RIGSE-369
**Repo**: https://github.com/concord-consortium/rigse
**Implementation Spec**: [implementation.md](implementation.md)
**Status**: **In Development**

## Overview

rigse's run path stops minting a Firebase class token for CLUE's project, and the setting and stack parameter that named CLUE's FirebaseApp for it go away. Packages read CLUE data through cc-data, so the Researcher Dashboard's runner no longer needs a path into CLUE's Firebase.

## Project Owner Overview

When a researcher runs a package from the Researcher Dashboard, rigse hands the runner a set of signed tokens. Until now, a package that declared it wanted CLUE data got an extra token able to read the class's documents in CLUE's own Firebase project. The CLUE pre-pull that used that token was removed on 2026-10-14: packages now read CLUE data through cc-data, the same way they read answers and logs, so the extra token has no reader.

This story deletes the code that minted it, the configuration that pointed at CLUE's FirebaseApp, and the stack parameter that set it on AWS, so the portal holds no runner path into CLUE's Firebase. It merges before rigse 2.31.0 (RIGSE-370), so production never receives the mint or the parameter. Nothing a researcher sees changes, and the portal keeps the CLUE FirebaseApp records that other features, including the dashboard's own CLUE activity listener, still use.

## Background

The Jira story is the authoritative scope; this spec records what the code check found and the requirements that follow from it.

RIGSE-368 built the run path (`POST /api/v1/researcher_dashboard/run_package`). `ResearcherDashboard::RunPackage` resolves each package at report-server, then posts to report-service's `researcherDashboard` function a body whose `class_tokens` maps a FirebaseApp name to a class runner token. The report-service app (`RESEARCHER_DASHBOARD_FIREBASE_APP`) always gets one; CLUE's app (`RESEARCHER_DASHBOARD_CLUE_FIREBASE_APP`) got a second whenever any resolved package's report-server answer carried `clue_prepull: true` (RIGSE-368 R20 and its "rigse cannot learn `clue_prepull`" decision). The setting is read per call, so a batch with `clue_prepull` on a portal without the setting answers 503 naming it.

The stream decided on 2026-10-14 (`final-design.md` item 16, the landing tracker's removal steps R1 to R6) to remove the CLUE pre-pull everywhere: RD-4 pass 2 deletes the runner's CLUE reader, REPORT-109 drops report-server's `clue_prepull` field and column, REPORT-152 stops cc-data writing it, and this story deletes rigse's half. Staging's `ResearcherDashboardClueFirebaseApp` stack parameter was already emptied on 2026-10-14 (change set `rigse-staging-remove-clue-firebase-app`), so staging's tasks have no `RESEARCHER_DASHBOARD_CLUE_FIREBASE_APP` and a `clue_prepull` batch there is refused with a 503 today.

The two sides of the wire after this story:

- **report-server's resolve answer** may still carry `clue_prepull` (true or false) until REPORT-109 deploys, and published manifests (REPORT-147's among them) may still say `clue_prepull: true`. rigse no longer reads it, so it cannot affect a run, and the name is gone from rigse's code and specs (Doug, 2026-10-15: adding it was a mistake).
- **report-service's `/run-package`** takes `class_tokens` as `Record<string, string>` (`functions/src/researcher-dashboard/run-package.ts`), and the runner looks its project's token up by `firebase_project` (`runner/server/runner.js`). A one-entry map is what every batch without `clue_prepull` already sends, so neither consumer changes.

The CLUE FirebaseApp rows stay. They are admin data (`/admin/firebase_apps`), not configuration this story owns, and the browser's plain researcher token for CLUE's activity documents (CLUE-693, RD-6 pass 2) is minted from them by `GET /api/v1/jwt/firebase?firebase_app=...&researcher=true&class_hash=...`, which reads the app named in the request and never `ResearcherDashboard::Settings`.

## Requirements

### The run path

- R1. `RunPackage` mints exactly one class runner token per run, in the report-service FirebaseApp (`Settings.firebase_app`). `class_tokens` stays a map from FirebaseApp name to token, with that one entry.
- R2. No run reads or requires `RESEARCHER_DASHBOARD_CLUE_FIREBASE_APP`, so a package whose manifest or resolve answer still declares the CLUE pre-pull runs like any other. This holds by construction: nothing in rigse reads the field (R3, R5).
- R3. `Catalog.resolve` returns `{identity, version, checksum, catalog_id}`. It reads nothing else from the resolve answer, so a field it does not name is accepted and ignored, as before.
- R4. Nothing else on the run path changes: the batch still resolves whole before anything is minted or sent, the session token, `firebase_project`, the assertions, the scope block, the 503 for an unset or row-less `RESEARCHER_DASHBOARD_FIREBASE_APP`, and every refusal mapping keep their current behavior and tests.

### Configuration

- R5. `ResearcherDashboard::Settings.clue_firebase_app` is deleted, and no code in `rails/` reads `RESEARCHER_DASHBOARD_CLUE_FIREBASE_APP`. `clue_prepull` appears nowhere in `rails/` (code and RSpec files), the compose file, the template or the README (Doug, 2026-10-15); only the closed RIGSE-368 spec and this spec still name it (Out of Scope).
- R6. `docker-compose.yml` no longer sets `RESEARCHER_DASHBOARD_CLUE_FIREBASE_APP`, and the spec helper's dashboard environment no longer sets it.
- R7. `configs/cloudformation/stack_template.yml` (the portal's stack template, which lives in rigse; the `cloud-formation` repo's portal templates carry none of the dashboard parameters) loses the `ResearcherDashboardClueFirebaseApp` parameter, the `ResearcherDashboardClueFirebaseAppDefined` condition, and the `RESEARCHER_DASHBOARD_CLUE_FIREBASE_APP` environment entry in both the app and the worker task definitions. The other dashboard parameters, conditions and entries are untouched.

### What stays

- R8. No CLUE `firebase_apps` row is deleted or changed, and no migration or data task is added. `jwt/firebase`'s researcher mint is untouched.
- R9. The class runner token's claims (`researcher_dashboard_runner: true`, `user_type: researcher`, `class_hash`) and its one-hour lifetime are unchanged.

### Prose

- R10. The README's dashboard section names only the settings and stack parameters that remain: the stack parameter list drops `ResearcherDashboardClueFirebaseApp`, the run path's needs no longer mention a CLUE app, the `RESEARCHER_DASHBOARD_CLUE_FIREBASE_APP` bullet is removed, and "Both FirebaseApp names" becomes the one.
- R11. Code comments that describe the CLUE token or CLUE's deny-write rules are deleted or corrected: `settings.rb`'s `TODO(RIGSE-369)` and its method comment go with the method, its module header says "which Firebase project" (singular) its runner tokens are minted in, `catalog.rb`'s "no CLUE token" comment goes with the field, `run_package.rb`'s mint comment goes with the line, and `runner_tokens.rb`'s header stops saying CLUE's rules deny the claim (CLUE-692 closed as not needed: no runner-claim rules exist in CLUE's project).

### Tests

- R12. The specs that existed for the CLUE mint (the CLUE token test, the CLUE "no row" refusal, the CLUE-unset context, and the catalog's "reads `clue_prepull`" test) are deleted with no replacement, and the resolve stubs and fixtures in the run path, catalog and controller specs stop carrying `clue_prepull` (Doug, 2026-10-15: the field does not live on in the code, tests included). The remaining run and catalog tests already pin the posted `class_tokens` to the one report-service key and the resolve result to its four keys.
- R13. The "configured FirebaseApp has no row" refusal is kept, aimed at the report-service app, so `fetch_firebase_app`'s missing-row branch stays covered.
- R14. The service and controller specs for the dashboard pass.

### Rollout

- R15. The stack update that drops the parameter is an outward step taken on Doug's go, not part of the merge. On staging the parameter is already empty, so the update removes no value from the running tasks; its change set is read before it is executed, and may or may not register new task definition revisions (either is acceptable). On production the template reaches the stack with rigse 2.31.0's release (RIGSE-370), whose first dashboard template update then never adds the parameter.
- R16. The code and the template can reach a stack in either order: new code ignores the variable if a stack still sets it, and old code on a stack without it refuses only `clue_prepull` batches, as staging already does. But the staging stack's template update is due no later than the first staging release of this code, because the release-portal skill's drift check (its step 3b) stops a release whose tag's template differs from the deployed one.

## Technical Notes

- **Files:** `rails/app/services/researcher_dashboard/{run_package,catalog,settings,runner_tokens}.rb`; `rails/spec/services/researcher_dashboard/{run_package,catalog}_spec.rb`; `rails/spec/support/researcher_dashboard_helper.rb`; `rails/spec/controllers/api/v1/researcher_dashboard_controller_spec.rb` (its resolve stub drops `clue_prepull: false`, R12); `docker-compose.yml:158`; `configs/cloudformation/stack_template.yml:285-288,308,623-627,889-893`; `README.md:690,701,705,707`.
- **Release mechanics.** The release-portal skill updates a stack with `--use-previous-template` and stops on template drift or a dropped parameter (its steps 3b and 3c). A template that lost a parameter is applied with `--template-body` and without that parameter in `--parameters`; passing `UsePreviousValue` for a key the new template lacks fails the update.
- **Wire contracts.** Unchanged in shape: `class_tokens` is `Record<string, string>` at report-service and the runner. Batches without `clue_prepull` already send one entry.

- **Verified by running it (throwaway, reverted; last on 2026-10-21 against `origin/master` `430b97d`).** The dashboard's service and controller specs pass at 137 examples, on `9f948f6` and on `430b97d` alike. With the deletions applied as `implementation.md` lays them out and the container's environment lacking `RESEARCHER_DASHBOARD_CLUE_FIREBASE_APP`, they pass at 133 (the CLUE token test, the CLUE-unset context's two examples and the catalog's `clue_prepull` test go). `git grep -i clue -- rails docker-compose.yml` then finds only `users_controller.rb:310`'s unrelated CLUE standalone comment. The template with the four blocks deleted is clean under `cfn-lint`, as `master`'s is.
- **RIGSE-374 on `master`.** `430b97d` (the `profile` capability for `/auth/user`) edits README lines 692 and 698 in place, so the line numbers and quoted text above are unchanged, and it touches nothing under `researcher_dashboard/`, `Settings`, `SignedJwt` or `jwt/firebase`.

## Out of Scope

- Deleting or editing the CLUE `firebase_apps` rows (R8).
- report-server's `clue_prepull` field, its parsing and its column (REPORT-109); cc-data's `package init` and `clue_source` (REPORT-152); the runner's CLUE reader (RD-4 pass 2).
- Running the stack update on staging or production (R15: Doug's go at rollout).
- Editing the closed RIGSE-368 spec, which records the run path as it was built. It is documentation, not code, so it keeps its `clue_prepull` text.
- `docs/testing-resource-launches-locally.md`'s CLUE launch notes, which are about launching CLUE, not the dashboard.

## Open Questions

### RESOLVED: Judgment call: keep `class_tokens` a map, or send one token
**Context**: With one Firebase project left, `class_tokens` could become a single `class_token` string.
**Options considered**:
- A) Keep the map with one entry.
- B) Replace it with a single field.

**Decision**: A. report-service's `/run-package` and the runner both consume the map, and a one-entry map is what every non-CLUE batch already sends; B would change a contract two other repos own for no gain.

### RESOLVED: Replace the CLUE tests, or only delete them
**Context**: The draft replaced the CLUE specs with tests that a `clue_prepull: true` answer changes nothing, which kept the name alive in the specs.
**Options considered**:
- A) Delete them, and drop `clue_prepull` from every stub and fixture.
- B) Replace them with tests that a `clue_prepull: true` answer changes nothing.

**Decision**: A (Doug, 2026-10-15, stage 8): adding `clue_prepull` was a mistake, and it should not live on in the code. Jira's "a manifest that still says `clue_prepull: true` runs without asking for CLUE" holds by construction, since nothing reads the field (R2, R3, R5).

### RESOLVED: Judgment call: leave the closed RIGSE-368 spec as it is
**Context**: `specs/RIGSE-368-...md` describes R20's CLUE mint and the setting.
**Options considered**:
- A) Leave it; it is a closed record of the run path as built.
- B) Annotate it.

**Decision**: A. Closed specs record their story; the README and code comments are the living description (R10, R11).

### RESOLVED: Low confidence: does the staging stack update restart the app and worker tasks
**Context**: R15 says the parameter is already empty on staging, so no value leaves the tasks. Whether CloudFormation still registers new task definition revisions (and so rolls the services) when an `!If` that already resolves to `AWS::NoValue` is deleted decides how the rollout step is described.
**Options considered**:
- A) No new revisions: the rendered task definitions are identical.
- B) New revisions and a rolling restart.

**Decision**: Neither is asserted. Settling it needs a change set on `learn-portal-staging`, which is a cloud step this story leaves to rollout. R15 says instead that the change set is read before it is executed: either outcome is acceptable, since the tasks' environment is the same, and a rolling restart of the portal is the same disruption every release causes.

## Self-Review

Roles: Senior Engineer, QA Engineer, DevOps Engineer (release), Security Engineer.

### DevOps Engineer

#### RESOLVED: Merging the template change makes the next staging release stop on drift
The release-portal skill updates with `--use-previous-template` and, in step 3b, diffs the deployed template against the tag's `configs/cloudformation/stack_template.yml`, stopping on any difference. Staging's deployed template still has the parameter (the 2026-10-14 change set kept the current template and only emptied the value), so the first staging release of this code stops unless the template update has happened. Fixed in place: R16 states the order constraint, and that code and template are otherwise order-independent.

### QA Engineer

#### RESOLVED: The controller spec's resolve stub was left to the implementer
Technical Notes said the controller spec's `clue_prepull: false` "can stay or go". Settled at stage 8: it goes, with every other `clue_prepull` in the specs (R12).

### Senior Engineer (second pass, 2026-10-19)

#### RESOLVED: R5's "specs" could be read as the `specs/` folder
The closed RIGSE-368 spec (lines 67 to 323) and this spec name `clue_prepull`, and Out of Scope keeps the former. Fixed in place: R5 names `rails/` code and RSpec files and states the two spec-folder exceptions.

#### RESOLVED: `settings.rb`'s module header still said "which Firebase projects"
`settings.rb:2` describes the module as choosing "which Firebase projects its runner tokens are minted in"; after the change there is one. Fixed in place: R11 and the implementation make it singular.

### Senior Engineer (third pass, 2026-10-21)

#### RESOLVED: The verification note cited a commit no branch holds
Technical Notes named `32095b0`, an earlier copy of the spec commit that the amend replaced, and only `9f948f6` as the code base while `origin/master` is now `430b97d`. Fixed in place: the note gives the 2026-10-21 rerun on `430b97d` (137 to 133) and records that RIGSE-374's merge leaves the cited README lines unchanged.
