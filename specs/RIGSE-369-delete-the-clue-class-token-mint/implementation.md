# Implementation Plan: Delete the CLUE class-token mint

**Jira**: https://concord-consortium.atlassian.net/browse/RIGSE-369
**Requirements Spec**: [requirements.md](requirements.md)
**Status**: **In Development**

## Implementation Plan

Two commits. The first removes everything the running code reads; the second removes the stack parameter, whose rollout is a separate outward step (R15, R16). Each leaves the suite green on its own.

### Delete the CLUE mint from the run path

**Summary**: `RunPackage` mints one class token, `Catalog.resolve` stops returning `clue_prepull`, `Settings.clue_firebase_app` goes, the specs that existed for the mint are deleted, `clue_prepull` leaves every stub and fixture, and compose and the README's settings text stop naming the variable. R1 to R6, R8 to R14, and R10's settings half.

**Files affected**:
- `rails/app/services/researcher_dashboard/run_package.rb`: drop the mint and its comment; `body` takes `firebase_app` only.
- `rails/app/services/researcher_dashboard/catalog.rb`: drop `clue_prepull` and its comment from the returned hash.
- `rails/app/services/researcher_dashboard/settings.rb`: delete `clue_firebase_app` and its comment and TODO; the module header's "which Firebase projects" becomes "which Firebase project" (R11).
- `rails/app/services/researcher_dashboard/runner_tokens.rb`: drop "and CLUE's rules use to deny them" from the header comment (R11).
- `rails/spec/support/researcher_dashboard_helper.rb`: drop the CLUE variable.
- `rails/spec/services/researcher_dashboard/run_package_spec.rb`: delete the CLUE tests and `stub_resolve`'s `clue_prepull` (R12); retarget the no-row test (R13).
- `rails/spec/services/researcher_dashboard/catalog_spec.rb`: the resolve result has four keys; delete the `clue_prepull` test and the fixture's field (R12).
- `rails/spec/controllers/api/v1/researcher_dashboard_controller_spec.rb`: the resolve stub drops `clue_prepull: false` (R12).
- `docker-compose.yml`: drop line 158.
- `README.md`: lines 701, 705 and 707 (the run path's needs, the CLUE bullet, "Both FirebaseApp names").

**Estimated diff size**: ~80 lines, nearly all deletions (the code, specs and compose file measured 15 insertions and 63 deletions as throwaway, before the README).

`run_package.rb`:

```ruby
# before
      firebase_app = Settings.firebase_app
      # Minted whenever a package asks for the CLUE pre-pull, whatever the runner does with
      # it: rigse learning the runner's configuration would be the wrong coupling.
      apps = [firebase_app]
      apps << Settings.clue_firebase_app if resolved.any? { |r| r[:clue_prepull] }
      url = "#{Settings.function_url}/run-package"

      response = Upstream.post_json(:function, url, body: body(resolved, apps, firebase_app),
# after
      firebase_app = Settings.firebase_app
      url = "#{Settings.function_url}/run-package"

      response = Upstream.post_json(:function, url, body: body(resolved, firebase_app),
```

```ruby
# before
    def body(resolved, apps, firebase_app)
      ...
        class_tokens: apps.index_with { |app| RunnerTokens.class_token(user: @user, clazz: @clazz, firebase_app: app) },
# after
    def body(resolved, firebase_app)
      ...
        class_tokens: { firebase_app => RunnerTokens.class_token(user: @user, clazz: @clazz, firebase_app: firebase_app) },
```

`body`'s `resolved.map { |r| r.slice(:identity, :version, :checksum, :catalog_id) }` stays as it is: it already sends only those four keys.

`catalog.rb`:

```ruby
# before
        # Absent on a report-server that predates the field: no CLUE token rather than a failed run.
        { identity: identity, version: version, checksum: body['checksum'], catalog_id: body['catalog_id'],
          clue_prepull: body['clue_prepull'] == true }
# after
        { identity: identity, version: version, checksum: body['checksum'], catalog_id: body['catalog_id'] }
```

`settings.rb`: delete the five lines from `# The FirebaseApp in CLUE's project` through the method's `end`, and the blank line after. `fetch_firebase_app` keeps its one caller, `firebase_app`. The module header's first sentence becomes "Where the dashboard's server-to-server calls go and which Firebase project its runner tokens are minted in."

`runner_tokens.rb` header:

```ruby
# before
  # The Firebase custom tokens a researcher's runner signs in with. Both carry
  # researcher_dashboard_runner, which report-service's rules require for the runner's
  # writes and CLUE's rules use to deny them; neither is ever returned to a browser.
  #
  # The session token names no class. A class token carries the class_hash the
  # class-scoped rules key on, one per Firebase project, since a custom token is signed by
  # one project's service account and cannot be exchanged in another.
# after
  # The Firebase custom tokens a researcher's runner signs in with. Both carry
  # researcher_dashboard_runner, which report-service's rules require for the runner's
  # writes; neither is ever returned to a browser.
  #
  # The session token names no class. A class token carries the class_hash the
  # class-scoped rules key on, one per Firebase project, since a custom token is signed by
  # one project's service account and cannot be exchanged in another.
```

The second paragraph is unchanged: it still explains why `class_tokens` is keyed by FirebaseApp name (R1).

`researcher_dashboard_helper.rb`: `ENVIRONMENT` keeps `REPORT_SERVER_URL`, `RESEARCHER_DASHBOARD_FUNCTION_URL` and `RESEARCHER_DASHBOARD_FIREBASE_APP`.

`run_package_spec.rb`:

- The `before(:each)` creates only the `report-service-dev` FirebaseApp.
- `'mints a CLUE class token when a package declares clue_prepull'` is deleted. The main posted-body example already expects `body['class_tokens'].keys` to eq `['report-service-dev']`.
- `stub_resolve` loses its `clue_prepull:` keyword and the field in the body it answers.
- `'when a configured FirebaseApp has no row'` deletes the `report-service-dev` row, stubs a plain resolve, and expects `NotConfigured` matching `/RESEARCHER_DASHBOARD_FIREBASE_APP names FirebaseApp report-service-dev, which does not exist/` with nothing posted (R13).
- The `'without the CLUE FirebaseApp configured'` context is deleted: its first example duplicates the main posted-body test, and its second asserts the refusal this story removes.

`catalog_spec.rb`:

- The first example expects `eq(identity: identity, version: '1.0.0', checksum: checksum, catalog_id: 12)`.
- `'reads clue_prepull, and treats its absence as false'` is deleted.
- The `answer` fixture drops `clue_prepull: false`.

`researcher_dashboard_controller_spec.rb`: the `POST run_package` resolve stub drops `clue_prepull: false`.

README, line 701 to 707:

- "and the run path needs `REPORT_SERVER_URL` and all three below, though the CLUE app only for packages that pre-pull CLUE documents;" becomes "and the run path needs `REPORT_SERVER_URL` and the two below;" (not "both below": the sentence's next clause, "both also sign an assertion", means the refresh and the run path).
- The `RESEARCHER_DASHBOARD_CLUE_FIREBASE_APP` bullet is deleted.
- "Both FirebaseApp names must be rows" becomes "The FirebaseApp name must be a row".

**Verification**: `docker compose run --rm app bundle exec rspec spec/services/researcher_dashboard spec/controllers/api/v1/researcher_dashboard_controller_spec.rb` passes, with four fewer examples than on `master` (137 to 133, checked as throwaway on `9f948f6` and on `430b97d`); `git grep -n -i 'clue_prepull\|clue_firebase\|CLUE_FIREBASE' -- rails docker-compose.yml README.md` finds nothing.

---

### Delete the CLUE FirebaseApp stack parameter

**Summary**: The template loses `ResearcherDashboardClueFirebaseApp`, its condition and its environment entry in both task definitions, and the README's stack parameter list drops it. R7 and R10's parameter half. Kept apart from the code commit because applying it to a stack is its own outward step (R15, R16).

**Files affected**:
- `configs/cloudformation/stack_template.yml`: lines 285 to 289 (the parameter and the blank line after it), 308 (the condition), 623 to 627 (the app task's `!If`), 889 to 893 (the worker task's `!If`).
- `README.md`: line 690's parameter list.

**Estimated diff size**: ~18 lines, all deletions bar the README sentence.

README line 690: "the `PortalSigningKey`, `PortalSigningKeyId`, `PortalPreviousVerifyKeys`, `ReportServerURL`, `ResearcherDashboardFunctionURL`, `ResearcherDashboardFirebaseApp` and `ResearcherDashboardClueFirebaseApp` stack parameters" becomes "... `ResearcherDashboardFunctionURL` and `ResearcherDashboardFirebaseApp` stack parameters".

**Verification**: `cfn-lint configs/cloudformation/stack_template.yml` is clean, as it is on `master`; `grep -c Clue configs/cloudformation/stack_template.yml` is 0.

## Rollout

Not part of the merge; each step on Doug's go.

1. **Staging** (R16: before or with the first staging release of this code). First diff the deployed template against the merged one, as the release-portal skill's step 3b does: only the four deleted blocks should differ. If anything else differs, stop and ask, since applying the template would carry that too. Then create a change set on `learn-portal-staging` (production AWS account, profile `default`) with `--template-body` from the merged `stack_template.yml` and every remaining parameter `UsePreviousValue=true`, listing parameters from the new template, not the stack, since naming `ResearcherDashboardClueFirebaseApp` fails the call. Read the change set: it should touch only `AppTaskDefinition` and `WorkerTaskDefinition`, if anything. Execute, then confirm the stack's parameters no longer list it and the portal answers 200.
2. **Production** goes with rigse 2.31.0 (RIGSE-370), whose release applies `master`'s template.

## Open Questions

### RESOLVED: Judgment call: one commit or two
**Context**: The whole change is under 100 lines.
**Options considered**:
- A) One commit.
- B) Code and its prose, then the template and its prose.

**Decision**: B. The template commit maps to a separate outward step (the stack update, R15 and R16), and a reviewer can check it against `cfn-lint` alone. Each commit leaves the suite and the template valid.

### RESOLVED: Judgment call: delete the CLUE-unset context outright
**Context**: Its first example, "still runs a batch without clue_prepull", is not about the mint.
**Options considered**:
- A) Keep that example at top level.
- B) Delete the whole context.

**Decision**: B. With the helper no longer setting the CLUE variable, every example runs without it, and the main posted-body example already covers an ordinary batch.

### RESOLVED: Keep `runner_tokens.rb`'s "one per Firebase project" sentence
**Context**: The draft deleted it with the CLUE phrase, which R11 does not ask for.
**Options considered**:
- A) Keep it.
- B) Delete it.

**Decision**: A (stage 8). It is still true and explains the keyed `class_tokens` map R1 keeps; only "and CLUE's rules use to deny them" goes.

## Self-Review

Roles: commit reviewer, test writer, operator, senior engineer.

### Operator

#### RESOLVED: The staging update could carry template changes beyond the parameter
Rollout step 1 applied the merged template without first checking what else differs from the deployed one. The template last changed in `0d9052a00` (RIGSE-368, 2026-10-01), and staging's dashboard settings were set on 2026-10-09 with the previous template; the release-portal drift check for staging's `v2.31.0-pre.6` (2026-10-21, image only) found the deployed template identical to `master`'s at `430b97d`. Fixed in place: step 1 diffs the deployed template first and stops if more than the four blocks differ, since a later release could still change it.

### Commit reviewer

No findings. Each commit stands alone: the first leaves the template untouched and valid, and nothing in `rails/` reads the parameter the second deletes. The two README edits touch different lines (690, and 701 to 707).

### Test writer

No findings. The changed specs were applied and run as throwaway (requirements Technical Notes): 133 examples pass. With no replacement tests (R12), the existing posted-body and catalog examples are what pin the one token and the four keys. Mutation check (2026-10-19): with `fetch_firebase_app`'s row check removed, the retargeted no-row example fails (`SignedJwt::Error: Unknown firebase app name`), so R13's test can fail.

### Commit reviewer (2026-10-21)

#### RESOLVED: The diff-size measurement predated the `settings.rb` header fix
The throwaway count was taken before R11 gained the singular "Firebase project", which adds one changed line. Re-measured on `430b97d` with the plan applied: 15 insertions and 63 deletions. Fixed in place.

### Documentation reviewer (2026-10-19)

#### RESOLVED: "both below" collided with "both also sign" in README line 701
The planned wording put two "both"s with different referents in one sentence. Fixed in place: "the two below".
