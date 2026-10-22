# RIGSE-369: Delete the CLUE class-token mint

**Jira**: https://concord-consortium.atlassian.net/browse/RIGSE-369

**Status**: **Closed**

## Overview

rigse's run path stops minting a Firebase class token for CLUE's project, and the setting and stack parameter that named CLUE's FirebaseApp for it go away. Packages read CLUE data through cc-data, so the Researcher Dashboard's runner no longer needs a path into CLUE's Firebase.

RIGSE-368 built the run path: `ResearcherDashboard::RunPackage` resolves each package at report-server, then posts to report-service's `researcherDashboard` function a body whose `class_tokens` maps a FirebaseApp name to a class runner token. The report-service app always got one; CLUE's app (`RESEARCHER_DASHBOARD_CLUE_FIREBASE_APP`) got a second whenever a resolved package's answer carried `clue_prepull: true`. The stream removed the CLUE pre-pull everywhere on 2026-10-14 (RD-4 pass 2 deletes the runner's CLUE reader, REPORT-109 drops report-server's field and column, REPORT-152 stops cc-data writing it); this story deletes rigse's half. Staging's `ResearcherDashboardClueFirebaseApp` parameter was already emptied that day.

## Requirements

### The run path

- R1. `RunPackage` mints exactly one class runner token per run, in the report-service FirebaseApp (`Settings.firebase_app`). `class_tokens` stays a map from FirebaseApp name to token, with that one entry.
- R2. No run reads or requires `RESEARCHER_DASHBOARD_CLUE_FIREBASE_APP`, so a package whose manifest or resolve answer still declares the CLUE pre-pull runs like any other. This holds by construction: nothing in rigse reads the field (R3, R5).
- R3. `Catalog.resolve` returns `{identity, version, checksum, catalog_id}`. It also requires a boolean `runnable` and refuses a package that is not runnable; any field it does not name, `clue_prepull` included, is accepted and ignored.
- R4. Nothing else on the run path changes: the batch still resolves whole before anything is minted or sent, and the session token, `firebase_project`, the assertions, the scope block, the 503 for an unset or row-less `RESEARCHER_DASHBOARD_FIREBASE_APP`, and every refusal mapping keep their behavior and tests.

### Configuration

- R5. `ResearcherDashboard::Settings.clue_firebase_app` is deleted, and no code in `rails/` reads `RESEARCHER_DASHBOARD_CLUE_FIREBASE_APP`. `clue_prepull` appears nowhere in `rails/` (code and RSpec files), the compose file, the template or the README; only the closed RIGSE-368 spec and this spec still name it.
- R6. `docker-compose.yml` no longer sets `RESEARCHER_DASHBOARD_CLUE_FIREBASE_APP`, and the spec helper's dashboard environment no longer sets it.
- R7. `configs/cloudformation/stack_template.yml` loses the `ResearcherDashboardClueFirebaseApp` parameter, the `ResearcherDashboardClueFirebaseAppDefined` condition, and the `RESEARCHER_DASHBOARD_CLUE_FIREBASE_APP` environment entry in both the app and the worker task definitions. The other dashboard parameters, conditions and entries are untouched.

### What stays

- R8. No CLUE `firebase_apps` row is deleted or changed, and no migration or data task is added. `jwt/firebase`'s researcher mint, which CLUE-693 and RD-6 pass 2 use for the browser's CLUE researcher token, is untouched.
- R9. The class runner token's claims (`researcher_dashboard_runner: true`, `user_type: researcher`, `class_hash`) and its one-hour lifetime are unchanged.

### Prose

- R10. The README's dashboard section names only the settings and stack parameters that remain.
- R11. Code comments that described the CLUE token or CLUE's deny-write rules are deleted or corrected: `settings.rb`'s TODO and method comment go with the method and its header says "which Firebase project" (singular), `catalog.rb`'s and `run_package.rb`'s CLUE comments go with their lines, and `runner_tokens.rb`'s header stops saying CLUE's rules deny the claim (CLUE-692 closed as not needed).

### Tests

- R12. The specs for the CLUE mint (the CLUE token test, the CLUE-unset context, and the catalog's `clue_prepull` test) are deleted with no replacement, and the resolve stubs and fixtures in the run path, catalog and controller specs stop carrying `clue_prepull`. The remaining run and catalog tests pin the posted `class_tokens` to the one report-service key and the resolve result to its four keys.
- R13. The "configured FirebaseApp has no row" refusal is kept, aimed at the report-service app, so `fetch_firebase_app`'s missing-row branch stays covered.
- R14. The service and controller specs for the dashboard pass.

### Rollout

- R15. The stack update that drops the parameter is an outward step, not part of the merge. On staging the parameter is already empty, so the update removes no value from the running tasks; its change set is read before it is executed. On production the template reaches the stack with rigse 2.31.0's release (RIGSE-370). *(Not part of the code change; see Not Yet Implemented.)*
- R16. The code and the template can reach a stack in either order, but the staging stack's template update is due no later than the first staging release of this code, because the release-portal skill's drift check (step 3b) stops a release whose tag's template differs from the deployed one. *(Rollout step; see Not Yet Implemented.)*

## Technical Notes

- **Files:** `rails/app/services/researcher_dashboard/{run_package,catalog,settings,runner_tokens}.rb`; `rails/spec/services/researcher_dashboard/{run_package,catalog}_spec.rb`; `rails/spec/support/researcher_dashboard_helper.rb`; `rails/spec/controllers/api/v1/researcher_dashboard_controller_spec.rb`; `docker-compose.yml`; `configs/cloudformation/stack_template.yml`; `README.md`.
- **Commits.** Two: the run path with its specs, compose line and README settings text; then the stack parameter with the README's parameter list. Each leaves the suite and the template valid.
- **Wire contracts.** Unchanged in shape: `class_tokens` is `Record<string, string>` at report-service's `/run-package` (`functions/src/researcher-dashboard/run-package.ts`) and the runner looks its token up by `firebase_project` (`runner/server/runner.js`). Batches without `clue_prepull` already sent one entry, so neither consumer changes.
- **Release mechanics.** The release-portal skill updates a stack with `--use-previous-template` and stops on template drift or a dropped parameter (its steps 3b and 3c). A template that lost a parameter is applied with `--template-body` and without that parameter in `--parameters`; passing `UsePreviousValue` for a key the new template lacks fails the update.
- **Verification.** The dashboard's service and controller specs go from 137 examples on `master` to 133 (the CLUE token test, the CLUE-unset context's two examples and the catalog's `clue_prepull` test). The template is clean under `cfn-lint`. The R13 no-row example fails when `fetch_firebase_app`'s row check is removed, so it can fail.

## Out of Scope

- Deleting or editing the CLUE `firebase_apps` rows (R8).
- report-server's `clue_prepull` field, its parsing and its column (REPORT-109); cc-data's `package init` and `clue_source` (REPORT-152); the runner's CLUE reader (RD-4 pass 2).
- Running the stack update on staging or production (R15).
- Editing the closed RIGSE-368 spec, which records the run path as it was built and keeps its `clue_prepull` text.
- `docs/testing-resource-launches-locally.md`'s CLUE launch notes, which are about launching CLUE, not the dashboard.

## Not Yet Implemented

- **Staging stack update** (R15, R16): due before or with the first staging release of this code. Diff the deployed template against the merged one first (only the four deleted blocks should differ; stop if anything else does). Then create a change set on `learn-portal-staging` with `--template-body` from the merged `stack_template.yml` and every remaining parameter `UsePreviousValue=true`, listing parameters from the new template, not the stack. Read the change set (it should touch only `AppTaskDefinition` and `WorkerTaskDefinition`, if anything), execute it, and confirm the parameter is gone and the portal answers 200. Left to rollout because it is a cloud change.
- **Production** gets the template with rigse 2.31.0 (RIGSE-370).

## Decisions

### Keep `class_tokens` a map, or send one token
**Context**: With one Firebase project left, `class_tokens` could become a single `class_token` string.
**Options considered**:
- A) Keep the map with one entry.
- B) Replace it with a single field.

**Decision**: A. report-service's `/run-package` and the runner both consume the map, and a one-entry map is what every non-CLUE batch already sent; B would change a contract two other repos own for no gain.

---

### Replace the CLUE tests, or only delete them
**Context**: The draft replaced the CLUE specs with tests that a `clue_prepull: true` answer changes nothing, which kept the name alive in the specs.
**Options considered**:
- A) Delete them, and drop `clue_prepull` from every stub and fixture, the controller spec's included.
- B) Replace them with tests that a `clue_prepull: true` answer changes nothing.

**Decision**: A (2026-10-15): adding `clue_prepull` was a mistake, and it should not live on in the code. Jira's "a manifest that still says `clue_prepull: true` runs without asking for CLUE" holds by construction, since nothing reads the field (R2, R3, R5).

---

### Leave the closed RIGSE-368 spec as it is
**Context**: `specs/RIGSE-368-...md` describes the CLUE mint and the setting.
**Options considered**:
- A) Leave it; it is a closed record of the run path as built.
- B) Annotate it.

**Decision**: A. Closed specs record their story; the README and code comments are the living description. R5 names `rails/` code and RSpec files so its "nowhere" does not reach the `specs/` folder.

---

### Does the staging stack update restart the app and worker tasks
**Context**: Whether CloudFormation registers new task definition revisions when an `!If` that already resolves to `AWS::NoValue` is deleted decides how the rollout step is described.
**Options considered**:
- A) No new revisions: the rendered task definitions are identical.
- B) New revisions and a rolling restart.

**Decision**: Neither is asserted, since settling it needs a change set on `learn-portal-staging`. The change set is read before it is executed; either outcome is acceptable, since the tasks' environment is the same and a rolling restart is the disruption every release causes.

---

### Merging the template change makes the next staging release stop on drift
**Context**: Staging's deployed template still has the parameter (the 2026-10-14 change set kept the template and only emptied the value), and the release-portal skill stops on any template difference.
**Options considered**:
- A) Leave the order to rollout.
- B) State the constraint in the requirements.

**Decision**: B. R16 states that the staging template update is due no later than the first staging release of this code, and that code and template are otherwise order-independent.

---

### Check the deployed template before applying the merged one
**Context**: Applying the merged template to staging carries every difference from the deployed one, not only the parameter.
**Options considered**:
- A) Apply it directly.
- B) Diff first, and stop if more than the four deleted blocks differ.

**Decision**: B. The deployed template matched `master`'s at `430b97d` (the `v2.31.0-pre.6` drift check), but a later release could still change it.

---

### One commit or two
**Context**: The whole change is under 100 lines.
**Options considered**:
- A) One commit.
- B) Code and its prose, then the template and its prose.

**Decision**: B. The template commit maps to a separate outward step (the stack update), and a reviewer can check it against `cfn-lint` alone.

---

### Delete the CLUE-unset context outright
**Context**: Its first example, a batch without the pre-pull, is not about the mint.
**Options considered**:
- A) Keep that example at top level.
- B) Delete the whole context.

**Decision**: B. With the helper no longer setting the CLUE variable, every example runs without it, and the main posted-body example already covers an ordinary batch.

---

### Keep `runner_tokens.rb`'s "one per Firebase project" sentence
**Context**: The draft deleted it along with the CLUE phrase.
**Options considered**:
- A) Keep it.
- B) Delete it.

**Decision**: A. It is still true and explains the keyed `class_tokens` map R1 keeps; only "and CLUE's rules use to deny them" goes.
