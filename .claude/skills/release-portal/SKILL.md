---
name: release-portal
description: Release and deploy the rigse portal to staging or production on AWS ECS. Tags a version, waits for the image build, applies Rails migrations as a one-off ECS task, updates the CloudFormation stack to the new image, and verifies the deployed version end to end. Use when asked to release, deploy, cut a version, ship to staging or production, or push the portal to AWS.
---

# Release the portal

Releases rigse by tagging a version, running migrations as a one-off ECS task, and
pointing the environment's CloudFormation stack at the new image.

**Deploying is a real, user-visible change.** Production serves live teachers and
students. Never run the production path without an explicit confirmation from the
user in the same conversation, and never skip the pre-flight checks to save time.

## Environment parameter

Takes one argument, `staging` or `production`.

**If the argument is absent, ask the user which environment before doing anything
else.** Use `AskUserQuestion` with those two options; this is a consequential,
discrete choice and it must not be guessed. Do not infer it from the branch, the
last release, or from context. If the user names an environment in prose ("ship it
to staging"), that counts as the argument being present.

## Environment configuration

Look these up rather than deriving them. **The two environments are not named
symmetrically** (`learn-portal-staging` vs `learn-ecs-production`), so any
pattern-based guess will be wrong for one of them.

| | staging | production |
|---|---|---|
| CloudFormation stack | `learn-portal-staging` | `learn-ecs-production` |
| ECS cluster | `staging` | `production` |
| App task family | `learn-portal-staging-App` | `learn-ecs-production-App` |
| Migrate task family | `learn-portal-staging-App-migrate` | `learn-ecs-production-App-migrate` |
| CloudWatch log group | `learn-portal-staging` | `learn-ecs-production` |
| Host | `learn.portal.staging.concord.org` | `learn.concord.org` |
| Version style | usually pre-release `vX.Y.Z-pre.N`, see step 2 | release `vX.Y.Z` |

Region is `us-east-1`, account `612297603577`, image repo
`ghcr.io/concord-consortium/rigse`. Confirm the AWS identity with
`aws sts get-caller-identity` before making changes.

Re-derive the cluster from the stack rather than trusting the table if anything
looks off:

```bash
aws cloudformation describe-stacks --stack-name "$(aws cloudformation describe-stacks \
  --stack-name "$STACK" --query "Stacks[0].Parameters[?ParameterKey=='ClusterStackName'].ParameterValue" \
  --output text)" --query "Stacks[0].Parameters[?ParameterKey=='EcsClusterName'].ParameterValue" --output text
```

## Do not use the GitHub Actions deploy workflow

`.github/workflows/deploy_backend_to_aws.yml` exists but is
**`state=disabled_manually` with zero runs**, and it is miswired for this repo: it
calls LARA's reusable workflow, which hardcodes `ParameterKey=LaraDockerImage`
while this stack uses `PortalDockerImage`. That workflow also contains its own
migration step, which is why it is easy to wrongly assume migrations are automatic
here. **Nothing runs migrations for rigse automatically.** Drive CloudFormation
directly, as below.

`docs/portal-authentication-unification-design.md` is unrelated; the deployment
reference is the LARA deployment doc, whose "Migrations" section still applies and
whose "Deploying New Code" section describes the console equivalent of step 6.

## Helper scripts

Three helper scripts ship with this skill, in its own `scripts/` directory. **Their
paths are relative to the skill, not to the repo.** The working directory throughout
a release is the rigse checkout, which has no top-level `scripts/`, so a bare
`scripts/verify-migration.sh` resolves to nothing and fails. Set `SKILL_DIR` from the
base directory reported when the skill was loaded, and invoke them through it:

```bash
SKILL_DIR=<the skill's base directory>   # as reported on load
```

| script | answers | source |
|---|---|---|
| `verify-migration.sh` | did *this* migrate task fail, and why | the task's Rails output |
| `check-migration-status.sh` | is the schema where it should be | `schema_migrations` in the database |
| `check-deployed-version.sh` | is the new image actually serving | the served footer |

The two migration scripts are complementary, not alternatives, and step 5 runs both.
Only the database knows which migrations are applied; only the log says why a run died.

## Reading the schema state

`schema_migrations` is the primary source for which migrations are applied: it is the
table Rails itself consults to decide what is still pending. Read it with
`db:migrate:status` whenever the question is *is the schema where it should be*, rather
than inferring it from a migrate task's log. The table survives log retention, does not
depend on the wording of Rails' output, and after a partial failure states exactly which
migrations are missing.

The database is only reachable from inside the VPC, so this runs as a one-off ECS task
and its output still arrives via CloudWatch. That is not the same as scraping the migrate
run's narration: the answer originates in the database, not in a process's claim about
itself.

**Do not register a task definition revision to read status.** The section on verifying a
migration that already ran treats revisions of the `-App-migrate` family as the audit
trail of what migrated, so a status-only revision would look exactly like a migration run
for that version. `run-task --overrides` can change the command (just not the image),
which is all this needs.

**Which task definition to override decides the argv**, because the image's entry point is
`rails` (`rails/Dockerfile`) and the two families treat it differently. Verified on both
environments: the container is named `App` in each.

**Pick exactly one of the next two lines.** They are alternatives, not a sequence, and
running both leaves you on the second with a possibly-unset `$REV`.

```bash
# Any time: the App family leaves entryPoint empty, so the image supplies `rails` and the
# command is the subcommand alone. This is why the App containers serve as `rails server`.
CMD='["db:migrate:status"]'; TD="${STACK}-App"

# Only right after step 5: that revision overrides entryPoint to ["bundle","exec"].
CMD='["rake","db:migrate:status"]'; TD="${STACK}-App-migrate:${REV}"

aws ecs run-task --cluster "$CLUSTER" --launch-type EC2 --count 1 \
  --started-by "rigse-migrate-status" --task-definition "$TD" \
  --overrides "{\"containerOverrides\":[{\"name\":\"App\",\"command\":${CMD}}]}" \
  --query '{taskArn:tasks[0].taskArn,failures:failures}'

STATUS_TASK=<last path segment of taskArn>
until [ "$(aws ecs describe-tasks --cluster "$CLUSTER" --tasks "$STATUS_TASK" \
        --query 'tasks[0].lastStatus' --output text)" = "STOPPED" ]; do sleep 10; done
```

Sending the other family's argv is a real and quiet failure rather than a typo that
corrects itself: `bundle exec rake db:migrate:status` against the App family composes into
`rails bundle exec rake db:migrate:status` and dies with `Unrecognized command "bundle"`,
exit 1, which is not a database error and produces no status table. The script detects that
specific case and says which argv the family wants.

**The image decides the file list, the database decides the applied list.** Both halves of
the status table come from different places, so a version can read as absent purely because
the task ran an older image. That is why a pre-flight read against the still-deployed image
reports the release's new migrations as `NOT IN IMAGE`, and why it is not an error there.

Then assert with the script, passing **version timestamps, not class names**:

```bash
"$SKILL_DIR"/scripts/check-migration-status.sh "$LOG_GROUP" "$STATUS_TASK" applied <version ...>
```

Mode `applied` requires every migration file in the image to be up. Mode `report` prints
the same state without failing on pending migrations, for reads taken before migrating.

The version is the timestamp, derived from the same filenames as step 3a:

```bash
git diff --name-only "$FROM_TAG".."$TARGET_REF" -- rails/db/migrate/ \
  | sed -n 's#.*/\([0-9]\{14\}\)_.*#\1#p'
```

Class names are wrong here, and the reason is in Rails rather than in the script:
`db:migrate` logs the camelized name (`AddFooToBars`) while `db:migrate:status` humanizes
the same name (`Add foo to bars`). A class name therefore matches `verify-migration.sh`'s
input and never this one. The version is identical in both outputs and in the filename.

A healthy read can still report `NO FILE` rows, and staging currently has two. Those are
versions recorded in the database whose migration file is not in the image, they are not a
migrate failure, and the script counts them apart from the real applied rows so they
cannot be read as pending work.

## Steps

### 1. Preconditions

- Working tree clean, on `master`, and `git pull` done. Releases are cut from master.
- `aws sts get-caller-identity` returns account `612297603577`.
- Report what is currently deployed before changing anything:

```bash
aws cloudformation describe-stacks --stack-name "$STACK" \
  --query 'Stacks[0].{Status:StackStatus,Updated:LastUpdatedTime,Image:Parameters[?ParameterKey==`PortalDockerImage`].ParameterValue}'
```

Abort if the stack is not in a settled state (`UPDATE_COMPLETE` or
`CREATE_COMPLETE`). Deploying onto an in-progress or rolled-back stack is how you
get a stuck stack.

The currently deployed image tag is the **from-version** for every diff below.

### 2. Choose the version

Versioning is semver from the commits since the last release: any `feat:` commit
means a minor bump, otherwise a patch bump. Check what is actually shipping:

```bash
git log --oneline "$FROM_TAG"..master
```

- **staging** usually cuts a pre-release, `vX.Y.Z-pre.N`. `N` starts at 0 and
  increments if that version already has pre-releases.
- **production** cuts the plain `vX.Y.Z` matching the pre-release that was verified
  on staging.

**Staging is not always a pre-release, and the alternative is arguably safer.** The
other flow is to cut the final `vX.Y.Z`, build it once, deploy that image to staging,
verify it, then promote the *identical image* to production. Production then runs the
exact artifact that was validated on staging rather than a separate rebuild of the
same commit. Do not treat a request for a non-pre tag on staging as a mistake to be
corrected. If the user has not made the style clear, ask which of the two they want
rather than assuming the pre-release flow.

Tags are **annotated** (`git tag -a`). Confirm the chosen version with the user
before creating it; a wrong version number is annoying to undo once pushed.

Note pre-release tags are **plain git tags, not GitHub Releases**. Do not create a
GitHub Release for them; the convention here is release objects only for final
versions, created in step 8.

### 3. Pre-flight checks

Run all four and report the results together **before** tagging. Each one has
bitten a real release.

**These checks run before step 4 creates the tag, so they must not reference
`$NEW_TAG`** as a git revision: it does not exist yet and every command below would
fail with `fatal: bad revision`. Resolve the target to a ref that exists now:

```bash
# A new release tags the current commit; a rollback targets an existing tag.
TARGET_REF=HEAD          # rollback: TARGET_REF="$NEW_TAG"
```

`$NEW_TAG` is still the name being *published*, and stays correct in step 4 onward
once the tag exists.

**a. Migrations that will apply.** This tells you whether step 5 is needed at all
and, critically, gives you the expected migration class names to verify against:

```bash
git diff --name-only "$FROM_TAG".."$TARGET_REF" -- rails/db/migrate/
```

Empty output means step 5 is skipped entirely. Say so in the report rather than
running the migrate task as a no-op.

This is a diff of files, not a reading of the database, so it says what the release
*adds* and not what is already applied. When the two could disagree, and they do
whenever staging was migrated ahead of the tag or a commit is being re-tagged,
confirm the starting point against `schema_migrations` (see Reading the schema state)
in `report` mode. A clean pre-flight read is zero pending migrations for the deployed
image; anything pending before you start is a leftover from an earlier release and
needs explaining first.

**b. CloudFormation template drift.** `--use-previous-template` in step 6 means
template changes in the release are *not* applied. If the template changed, that is
silent and wrong:

```bash
aws cloudformation get-template --stack-name "$STACK" --template-stage Original \
  --query 'TemplateBody' --output text > /tmp/deployed-template.yml
git show "$TARGET_REF":configs/cloudformation/stack_template.yml > /tmp/tag-template.yml
diff -B <(sed 's/[[:space:]]*$//' /tmp/deployed-template.yml) <(sed 's/[[:space:]]*$//' /tmp/tag-template.yml)
```

Strip trailing whitespace on both sides **and pass `-B`**. Both are needed and they
fix different things. The `sed` handles trailing whitespace within a line; `-B`
handles the extra trailing *blank line* the deployed copy comes back with, which the
`sed` cannot touch because an empty line has no trailing whitespace to strip.
Without `-B` this check reports `952d951` on every single run, and the rule below
then aborts every release on a difference that is not real. A genuine template change
still shows through `-B`.

**If the templates differ, stop and ask the user how to proceed.** Applying the new
template means passing `--template-body` from the tag instead of
`--use-previous-template`, which can change resources far beyond the image. Show
them the diff and let them decide.

**c. New or dropped stack parameters.** A new template parameter has no value on the
existing stack and must be supplied explicitly:

```bash
# parameter names in the tag's template
python3 -c "
import re
t=open('/tmp/tag-template.yml').read()
m=re.search(r'^Parameters:\n(.*?)^[A-Za-z]',t,re.S|re.M)
print('\n'.join(sorted(re.findall(r'^  ([A-Za-z0-9]+):',m.group(1),re.M))))
" | LC_ALL=C sort > /tmp/tag-params.txt
aws cloudformation describe-stacks --stack-name "$STACK" \
  --query 'Stacks[0].Parameters[].ParameterKey' --output text | tr '\t' '\n' | LC_ALL=C sort > /tmp/stack-params.txt
echo "need values:"; LC_ALL=C comm -23 /tmp/tag-params.txt /tmp/stack-params.txt
echo "dropped:";     LC_ALL=C comm -13 /tmp/tag-params.txt /tmp/stack-params.txt
```

Sort both with `LC_ALL=C`. Mismatched locale collation produces phantom differences
that look like real drift. If either list is non-empty, stop and ask the user for
the new values or confirmation.

**d. Direction of the deploy.** Establish whether this moves the environment
forwards, sideways, or backwards, and **ask the user before proceeding on anything
that is not a clean forward deploy.** Do not refuse a backwards deploy: a rollback is
a legitimate, deliberate downgrade (see Rollback below), and the point of this check
is to distinguish a deliberate one from an accident.

Compare **commit ancestry, not version strings.** `sort -V` orders `v2.30.0` before
`v2.30.0-pre.0`, the reverse of semver, so a version-string comparison reports every
staging-to-production promotion as a downgrade.

```bash
DEPLOYED_VER="${DEPLOYED_IMAGE##*:}"        # from step 1, e.g. 2.29.1
DEPLOYED_TAG="v${DEPLOYED_VER}"
git fetch --tags --quiet

if [ "$DEPLOYED_TAG" = "$NEW_TAG" ]; then
  echo "SAME version already deployed"
elif ! git rev-parse -q --verify "${DEPLOYED_TAG}^{commit}" >/dev/null; then
  echo "UNKNOWN: deployed tag $DEPLOYED_TAG not found in this repo"
elif [ "$(git rev-parse "${TARGET_REF}^{commit}")" = "$(git rev-parse "${DEPLOYED_TAG}^{commit}")" ]; then
  echo "SAME COMMIT under a different tag (normal pre-release to release promotion)"
elif git merge-base --is-ancestor "$TARGET_REF" "$DEPLOYED_TAG"; then
  echo "DOWNGRADE: $NEW_TAG is an ancestor of the deployed $DEPLOYED_TAG"
elif git merge-base --is-ancestor "$DEPLOYED_TAG" "$TARGET_REF"; then
  echo "FORWARD: $DEPLOYED_TAG is an ancestor of $NEW_TAG"
else
  echo "DIVERGENT: $NEW_TAG and $DEPLOYED_TAG share no ancestry"
fi
```

How to treat each result:

- **FORWARD** is the normal case. Continue.
- **SAME COMMIT** means the target and the deployed image are the same commit under
  two different tags. That is the normal staging-to-production promotion, and it also
  occurs **on staging** when the final `vX.Y.Z` is cut on the commit staging already
  runs as `vX.Y.Z-pre.N` (the build-once flow in step 2). Continue, and say so in the
  report. Note this is not a no-op deploy: the image tag differs, so CloudFormation
  does have a change to make, unlike the SAME version case below.
- **SAME version** means there is nothing for CloudFormation to change. It rejects a
  no-op update with `No updates are to be performed`, so step 6 fails rather than
  doing anything, and re-pointing the parameter at the image it already holds cannot
  restart anything. Ask what the user actually wants. If it is a restart, use
  `RestartToggle` (see "Forcing a restart" below) and skip the rest of this skill.
- **DOWNGRADE** needs an explicit confirmation, and the user must be told that
  **migrations are not reversed**. If any migration between the two versions was
  destructive or non-additive, the older code will be running against a schema it
  does not expect. Report which migrations sit between the two versions
  (`git diff --name-only "$TARGET_REF".."$DEPLOYED_TAG" -- rails/db/migrate/`) so the
  decision is informed.
- **DIVERGENT** or **UNKNOWN** means the tags are not comparable, usually a tag that
  was never fetched or an image not built from a tag. Stop and ask; do not guess.

### 4. Tag, push, and wait for the image

```bash
git tag -a "$NEW_TAG" -m "<version> <short description>"
git push origin "$NEW_TAG"
VERSION_NO_V="${NEW_TAG#v}"   # image tags drop the v; used by steps 5 and 6
```

CI builds on tag push. **Wait for it and confirm it is green** before deploying;
do not deploy an untested image. Use a `Monitor` on the run rather than polling.

Find the run by the tag it was pushed for, since `headBranch` carries the tag name:

```bash
gh run list --limit 10 --json databaseId,headBranch,status \
  --jq ".[] | select(.headBranch==\"${NEW_TAG}\") | \"\(.databaseId) \(.status)\""
```

**Use `--jq`, not `--template`.** `--template` renders `databaseId` through Go's
default float formatting and prints it as `3.1089915042e+10`, which is not a usable
run ID. Give the push a few seconds before the first query: an empty list right after
`git push` means the run has not registered yet, not that CI failed to fire.

Gate the `Monitor` on the run's own `status` reaching `completed`, and report each
job as it finishes so a failure is visible immediately rather than at the end. The
`Deploy application` job showing as `skipped` is expected: that is the disabled
workflow described above, not a problem with the build.

The image tag drops the `v` prefix (`docker/metadata-action` with
`type=semver,pattern={{version}}`), so `v2.30.0-pre.0` publishes as:

```
ghcr.io/concord-consortium/rigse:2.30.0-pre.0
```

Pre-releases do **not** get floating `{{major}}.{{minor}}` tags, so a pre-release can
never move a tag something else follows. Package read scope is usually unavailable,
so treat the green build job as proof of publication rather than querying the
registry.

### 5. Apply migrations

Skip only if step 3a found no new migration files. Migrations run **before** the
stack update: additive migrations are backward compatible with the old containers
still serving traffic, and the deploy then starts containers with a fresh schema
cache. Running migrations after the deploy requires a container restart, since
Rails caches the schema in its models.

**Base the new task definition on the live App task definition, never on the
existing `*-migrate` family.** The migrate family goes stale: on staging it still
carried an obsolete `DB_HOST` pointing at a bare RDS instance endpoint rather than
the Aurora cluster writer endpoint. Copying it would run migrations against the
wrong endpoint.

**`run-task --overrides` cannot change the image**, only command, environment, cpu
and memory. Registering a new revision is mandatory, not a convenience.

The generated file contains **every environment variable from the task definition in
plaintext**, including `DB_PASSWORD`, `JWT_HMAC_SECRET`, `DEVISE_SECRET_KEY` and the
SMTP and S3 credentials. Create it with a restrictive umask in a private temp file
and delete it on exit, so an aborted release cannot leave secrets readable in a
predictable location. Never print it.

```bash
TD=$(umask 077; mktemp)
trap 'rm -f "$TD"' EXIT

aws ecs describe-task-definition --task-definition "${STACK}-App" --output json \
 | jq --arg fam "${STACK}-App-migrate" --arg img "ghcr.io/concord-consortium/rigse:${VERSION_NO_V}" '
     .taskDefinition
     | del(.taskDefinitionArn,.revision,.status,.requiresAttributes,.compatibilities,.registeredAt,.registeredBy,.deregisteredAt)
     | .family = $fam
     | .containerDefinitions[0].image = $img
     | .containerDefinitions[0].entryPoint = ["bundle","exec"]
     | .containerDefinitions[0].command = ["rake","db:migrate"]' > "$TD"

REV=$(aws ecs register-task-definition --cli-input-json file://"$TD" \
  --query 'taskDefinition.revision' --output text)
echo "registered ${STACK}-App-migrate:${REV}"
```

The entry point override to `bundle exec` matters: the image's own entrypoint is
`rails`, so a bare `rake,db:migrate` command would compose into `rails rake
db:migrate`.

Before running, sanity-check that the generated task definition has the same
`DB_HOST` as the live App task definition (query the single field rather than
dumping the file).

```bash
aws ecs run-task --cluster "$CLUSTER" --launch-type EC2 --count 1 \
  --started-by "rigse-${VERSION_NO_V}-migrate" \
  --task-definition "${STACK}-App-migrate:${REV}" \
  --query '{taskArn:tasks[0].taskArn,failures:failures}'

TASK_ID=<last path segment of taskArn>
until [ "$(aws ecs describe-tasks --cluster "$CLUSTER" --tasks "$TASK_ID" \
        --query 'tasks[0].lastStatus' --output text)" = "STOPPED" ]; do sleep 10; done
aws ecs describe-tasks --cluster "$CLUSTER" --tasks "$TASK_ID" \
  --query 'tasks[0].{exit:containers[0].exitCode,stopCode:stopCode,reason:containers[0].reason}'
```

Require exit code `0`. Then **verify from the logs**, because an exit code says the
container exited cleanly, not which migrations ran:

```bash
"$SKILL_DIR"/scripts/verify-migration.sh "$LOG_GROUP" "$TASK_ID" <ExpectedMigrationClass ...>
```

Pass the class names derived in step 3a. The script polls, because the CloudWatch
stream can lag the task by up to a minute, and it treats "no migrations applied" as
a warning rather than success.

Then **confirm the schema itself**, because the log only reports what Rails narrated:

```bash
# reuse this release's migrate revision, overriding just the command (see Reading the
# schema state); do not register another revision
"$SKILL_DIR"/scripts/check-migration-status.sh "$LOG_GROUP" "$STATUS_TASK" applied <version ...>
```

Pass the version timestamps for the same migrations, not their class names. This is
the assertion that actually establishes the schema is current: `verify-migration.sh`
can only report that a run printed success, while this reads `schema_migrations` and
fails if any migration in the image is still pending. Requiring both closes the case
where the migrate task exits 0 having silently applied nothing, which the log check
reports as a warning that is easy to read past.

**Record `$TASK_ID` in the step 9 report.** It is the only cheap handle on this run's
log once the task ages out of ECS, and the next release may need it.

**If it fails, do not simply abort and assume the database is untouched.** This
stack runs MySQL, where DDL is not transactional, so a run that fails partway
through several migrations leaves the earlier ones committed and recorded in
`schema_migrations` while the later ones are not. The schema is then consistent with
neither the old nor the new image. Establish exactly how far it got and report that to
the user before resolving forward. Do not re-run blindly and do not start the stack
update.

**Use `check-migration-status.sh` in `report` mode to establish this**, rather than
the migrate log. A run that died partway logs only what printed before the abort, and
its last line may be a migration that was committed, one that was rolled back, or
neither, whereas the pending list is the schema's own account of what remains. Compare
that against the expected list from step 3a; the verifier's `applied:` line is
corroboration, not the primary record.

#### Verifying a migration that already ran

Releases frequently reach this step with the migration already applied: staging was
migrated days earlier, or the same commit is being re-tagged and promoted. The user
may also simply ask you to double-check. **Do not re-run the migrate task to find
out.** Establish it from the durable records instead.

**Read `schema_migrations` first.** It answers the question directly and it is the
only record here that cannot go stale: see Reading the schema state, in `applied`
mode, against the App family. The two checks below are inference from surrounding
artifacts, and are worth keeping for the history they show, but neither is evidence of
the schema's contents. This is also the case the log check handles worst, since a
migration applied days ago may have aged out of CloudWatch entirely.

**The migrate family's task definition revisions are the audit trail.** Every release
registers one, and its image tag says which version it migrated:

```bash
for r in $(aws ecs list-task-definitions --family-prefix "${STACK}-App-migrate" \
           --sort DESC --query 'taskDefinitionArns[:4]' --output text | tr '\t' '\n'); do
  aws ecs describe-task-definition --task-definition "$r" \
    --query 'taskDefinition.{rev:taskDefinitionArn,img:containerDefinitions[0].image,at:registeredAt}' --output text
done
```

Slice inside the query (`taskDefinitionArns[:4]`) rather than passing `--max-items`.
With `--output text`, `--max-items` appends the pagination token as a literal `None`
line, which the loop then feeds to `describe-task-definition` and fails with
`ClientException: Unable to describe task definition`.

Registration proves the run was *prepared*, not that it succeeded, so confirm from
the log. **ECS retains STOPPED tasks for only about an hour**, so
`list-tasks --desired-status STOPPED` is empty for anything older and is not an audit
trail; the task definition's `registeredAt` is what you correlate against instead.

The migrate task logs to `portal/App/<task-id>` in the same log group as the web
tasks, so **it is not distinguishable by stream name**. Match the stream whose last
event is shortly after that revision's `registeredAt`, then read that one stream:

```bash
aws logs describe-log-streams --log-group-name "$LOG_GROUP" \
  --order-by LastEventTime --descending --max-items 20 \
  --query 'logStreams[].{stream:logStreamName,last:lastEventTimestamp}' --output text

aws logs get-log-events --log-group-name "$LOG_GROUP" \
  --log-stream-name "portal/App/<task-id>" --start-from-head \
  --query 'events[].message' --output text
```

A successful run shows `== <timestamp> <Class>: migrated`.

**Never scan the whole log group.** `aws logs filter-log-events` across the group
walks every stream and times out (over two minutes in practice) even with a filter
pattern and a `--start-time`. Always target the single stream.

### 6. Update the CloudFormation stack

`--use-previous-template` is deliberate: it changes only the image parameter and
cannot drag in template drift from the working tree. Step 3b is what licenses it.

```bash
PARAMS=$(aws cloudformation describe-stacks --stack-name "$STACK" \
  --query "Stacks[0].Parameters[?ParameterKey!='PortalDockerImage'].ParameterKey" --output json \
  | jq -r 'map("ParameterKey=" + . + ",UsePreviousValue=true") | join(" ")')

aws cloudformation update-stack \
  --stack-name "$STACK" \
  --use-previous-template \
  --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
  --parameters $PARAMS ParameterKey=PortalDockerImage,ParameterValue=ghcr.io/concord-consortium/rigse:${VERSION_NO_V}
```

**For production, confirm with the user immediately before running this.** It starts
a rolling replacement of live tasks.

Watch it with a `Monitor`. **Filter stack events by timestamp against the update's
start time**, or the previous update's `UPDATE_COMPLETE` events will appear and look
like this deploy finishing. Gate completion on `describe-stacks` returning a terminal
status, not on seeing any particular event:

```bash
aws cloudformation describe-stacks --stack-name "$STACK" --query 'Stacks[0].StackStatus' --output text
```

`UPDATE_COMPLETE` is success. Anything containing `ROLLBACK` is a failure: report it
with the failing resource's status reason and stop. The App service is slower than
the Worker service because web tasks drain connections before old tasks stop.

### 7. Verify the deployment

Three checks, in order. All three must pass before reporting success.

**a. Stack.** `UPDATE_COMPLETE`, with `LastUpdatedTime` matching this update and
`PortalDockerImage` set to the new image.

**b. Running tasks are all on the new image. This is the authoritative check for
rollout completeness**, because it inspects every task directly rather than sampling
whatever the load balancer happens to hand you:

```bash
aws ecs list-tasks --cluster "$CLUSTER" --family "${STACK}-App" --desired-status RUNNING \
  --query 'taskArns' --output text | tr '\t' '\n' | while read -r t; do
    [ -z "$t" ] && continue
    aws ecs describe-tasks --cluster "$CLUSTER" --tasks "$t" --query 'tasks[0].containers[0].image' --output text
  done | sort | uniq -c
```

Every line must show the new image. Any remaining old-image task means the rollout
is incomplete.

**c. The served footer reports the new version.** An end-to-end smoke test that the
image actually boots and serves, which (a) and (b) cannot tell you. It is *not* a
completeness check: it samples traffic, so treat (b) as the authority on whether
every task rolled.

Size the streak against the fleet rather than using a fixed number. Production runs
many more App tasks than staging and the count varies with autoscaling, so any
constant baked in here is wrong somewhere: with a couple of dozen tasks, a streak of
10 still passes most of the time while a stale task is serving. Count the tasks at
runtime:

```bash
NEED=$(( $(aws ecs list-tasks --cluster "$CLUSTER" --family "${STACK}-App" \
           --desired-status RUNNING --query 'length(taskArns)' --output text) * 3 ))
MAX=$(( NEED * 5 * 3 ))
if [ "$MAX" -lt 900 ]; then MAX=900; fi   # never below the script default
"$SKILL_DIR"/scripts/check-deployed-version.sh "$HOST" "$NEW_TAG" "$NEED" "$MAX"
```

**Size the deadline from `NEED`, not the script's 900s default.** The script polls
every 5s and resets the streak on any flap or failed request, so `NEED` alone implies
`NEED * 5` seconds of *uninterrupted* agreement as a floor. On a 30-task fleet that
is `NEED=90`, a 450s floor, and two or three flaps put a perfectly healthy deploy
past 900s and report a false failure. Passing `NEED * 15` leaves room for the streak
to restart a couple of times.

**This must require consecutive agreement, not a single request.** During a rollout
the ALB balances across both task generations and the footer flaps: a real deploy
returned the new version on 4 of 10 requests mid-rollout, so one lucky curl reports
success while half of all users are still on the old code.

Note the footer shows the **git tag with the `v` prefix** (`v2.30.0-pre.0`), not the
image tag. It comes from `CC_PORTAL_IMAGE_VERSION`, baked into the image at build
time from `github.ref_name`. It is better evidence than the stack's
`CC_PORTAL_VERSION` parameter, which is stale and unrelated.

### 8. Create the GitHub Release (final versions only)

Step 2 says the convention is release objects for final versions only, and no other
step creates one, so it falls here. Do it **after** the verifications pass, so the
release object never advertises a version that failed to roll out:

```bash
gh release create "$NEW_TAG" --title "$NEW_TAG" --generate-notes
```

**Skip this entirely for a pre-release** (`vX.Y.Z-pre.N` stays a plain git tag) and
for a rollback (the release object already exists). Confirm with the user before
publishing: it is outward-facing and notifies watchers. If the same commit already
shipped to staging under a pre-release tag, the release object still belongs on the
final tag, not the pre-release one.

### 9. Report

State the environment, the version deployed, the from-version, which migrations
applied (with the migrate task ID from step 5, or that there were none), the schema
state confirmed from `schema_migrations`, and the three verification results.
Mention anything deferred or skipped, including a GitHub Release you did not create.

If the release enables a feature behind a flag or an admin setting, say so
explicitly: the deploy alone may not make the feature live.

## Forcing a restart without a new version

To restart the running containers on the image already deployed, change the
`RestartToggle` stack parameter. The template exists for exactly this and documents
it as "change this value to cause a rolling restart of the containers running portal
code. This is necessary after running migrations."

Changing it changes the `RESTART_TOGGLE` environment variable in the App and Worker
containers, which registers new task definition revisions and makes ECS roll the
services. Redeploying the same image cannot do this, because CloudFormation sees no
change at all.

The value is arbitrary and follows no convention: it only has to differ from
whatever the stack currently holds, and each environment holds something different.
Read the current value at runtime rather than assuming one, then set something
distinct; a timestamp is self-documenting.

```bash
CURRENT=$(aws cloudformation describe-stacks --stack-name "$STACK" \
  --query "Stacks[0].Parameters[?ParameterKey=='RestartToggle'].ParameterValue" --output text)
NEW="restart-$(date -u +%Y%m%dT%H%M%SZ)"    # any value != "$CURRENT"

PARAMS=$(aws cloudformation describe-stacks --stack-name "$STACK" \
  --query "Stacks[0].Parameters[?ParameterKey!='RestartToggle'].ParameterKey" --output json \
  | jq -r 'map("ParameterKey=" + . + ",UsePreviousValue=true") | join(" ")')

aws cloudformation update-stack --stack-name "$STACK" --use-previous-template \
  --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
  --parameters $PARAMS ParameterKey=RestartToggle,ParameterValue="$NEW"
```

**The version checks in step 7 do not verify a restart**, since the image and
therefore the footer version are unchanged. Verify instead that the tasks are new,
by confirming the App task definition revision incremented and that the running
tasks have recent `startedAt` times:

```bash
# --output text returns every match on one tab-separated line, so split before
# taking one, and match AppService specifically or you get the Solr service.
SVC=$(aws ecs list-services --cluster "$CLUSTER" --output text \
  --query "serviceArns[?contains(@, '${STACK}-AppService')]" | tr '\t' '\n' | head -1)

aws ecs describe-services --cluster "$CLUSTER" --services "$SVC" \
  --query 'services[0].{taskDef:taskDefinition,running:runningCount,deployments:deployments[].{status:status,rollout:rolloutState,updated:updatedAt}}'
```

A completed restart shows a single `PRIMARY` deployment with `rolloutState`
`COMPLETED` and an incremented task definition revision.

This is also the escape hatch if migrations ever get applied **after** a deploy
rather than before: Rails caches the schema in its models at boot, so the containers
must be restarted before they will see new columns.

## Rollback

Re-run step 6 with the previous image tag. Migrations are **not** rolled back;
if the release included a destructive migration, rolling back the image is not
sufficient and the user needs to be told that directly.

A rollback is a deliberate downgrade, so pre-flight check 3d will report
`DOWNGRADE`. That is expected here and is not a reason to stop; confirm it with the
user and continue. Skip the tagging step (step 4), since the target tag and its
image already exist.
