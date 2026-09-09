#!/usr/bin/env bash
# Verify the portal's schema state from the database's own record of applied migrations.
#
# This reads `db:migrate:status`, whose answer comes from the `schema_migrations` table.
# That table is the primary source: it is what Rails itself consults to decide which
# migrations are still pending. Prefer it over verify-migration.sh whenever the question
# is "is the schema where it should be", because:
#
#   - it survives log retention, so a release migrated days ago is still verifiable,
#   - it does not depend on the wording of Rails' migrate output, and
#   - after a partial failure it says exactly which migrations are missing, where the
#     migrate log only shows what printed before the abort.
#
# verify-migration.sh keeps its own job: it answers "did this specific task fail, and
# why", which the table cannot tell you. Use both.
#
# The transport is still CloudWatch, because the database is only reachable from inside
# the VPC and this runs as a one-off ECS task. That is not the same thing as scraping the
# migrate run's narration: the *source* here is the database, not the process's own claim
# about what it did.
#
# usage: check-migration-status.sh <log-group> <task-id> <mode> [expected-version ...]
#
#   mode applied  every migration file in the image must be up. Any pending migration
#                 fails. This is the post-migration assertion for step 5.
#   mode report   print the schema state without failing on pending migrations. This is
#                 the pre-flight read, where pending migrations are the expected answer.
#
# Expected migrations are given as **version timestamps, not class names**, e.g.
# 20260430123456. This differs from verify-migration.sh on purpose, and the difference is
# in Rails, not here: `db:migrate` logs the camelized class ("AddFooToBars") while
# `db:migrate:status` humanizes the same name ("Add foo to bars"), so a class name matches
# one output and never the other. The version is identical in both and in the filename:
#
#   git diff --name-only "$FROM_TAG".."$TARGET_REF" -- rails/db/migrate/ \
#     | sed -n 's#.*/\([0-9]\{14\}\)_.*#\1#p'
#
# The log group is the environment's own group (learn-portal-staging or
# learn-ecs-production) and streams are "portal/App/<task-id>" in both.
set -uo pipefail

if [ "$#" -lt 3 ]; then
  echo "usage: $(basename "$0") <log-group> <task-id> <applied|report> [expected-version ...]" >&2
  echo "  e.g. $(basename "$0") learn-portal-staging abc123 applied 20260430123456" >&2
  exit 2
fi

GROUP="$1"; TASK_ID="$2"; MODE="$3"; shift 3
EXPECTED=("$@")
STREAM="portal/App/${TASK_ID}"

case "$MODE" in
  applied|report) ;;
  *) echo "FAIL: mode must be 'applied' or 'report', got '${MODE}'" >&2; exit 2 ;;
esac

# Versions are 14-digit timestamps. Validating them here turns a typo into an immediate
# error instead of a confusing "expected migration not found" against a healthy schema.
for want in ${EXPECTED+"${EXPECTED[@]}"}; do
  if ! [[ "$want" =~ ^[0-9]+$ ]]; then
    echo "FAIL: expected migration '${want}' is not a version timestamp" >&2
    echo "  pass versions (20260430123456), not class names (AddFooToBars)" >&2
    exit 2
  fi
done

DEADLINE=$((SECONDS + 300))
ERR_RE="rake aborted!|ActiveRecord::(StatementInvalid|NoDatabaseError)|Mysql2::Error|Schema migrations table does not exist"
# The image's entry point is "rails", so an argv meant for the migrate family's
# ["bundle","exec"] entry point composes into `rails bundle exec ...` when it is sent to
# the App family instead. Rails names the offending word and exits 1, which matches no
# database error, so without this the run would poll the full deadline before reporting a
# missing status table. Diagnosed separately because the fix is the argv, not the schema.
ARGV_RE="Rails::Command::UnrecognizedCommandError|Unrecognized command"
ROW_RE="^[[:space:]]*(up|down)[[:space:]]+[0-9]+"

echo "reading schema state from ${STREAM} in ${GROUP}"

# The status table has no terminal marker, so completeness cannot be detected from a
# sentinel line the way a migrate run's "migrated (" can be. Poll until the row count
# stops growing across two consecutive reads instead. The portal prints over five hundred
# rows and the stream fills incrementally, so a single read can easily catch a partial
# table and report healthy migrations as missing.
LOG=""; ROWS=""; prev_count=-1
while [ $SECONDS -lt $DEADLINE ]; do
  ERR=$(mktemp); LOG=$(aws logs get-log-events --log-group-name "$GROUP" --log-stream-name "$STREAM" \
        --start-from-head --query 'events[].message' --output text 2>"$ERR") || LOG=""
  # Only a missing *stream* is benign: the task may not have logged yet. Anything else
  # fails now rather than being polled into a misleading timeout at the deadline. Match
  # the message, not the exception type, because a missing log group raises the same
  # ResourceNotFoundException yet will never appear, and a wrong region or a transposed
  # group name presents as exactly that.
  if [ -s "$ERR" ] && ! grep -q "log stream does not exist" "$ERR"; then
    echo "FAIL: AWS error while reading logs"; cat "$ERR"; rm -f "$ERR"; exit 1
  fi
  rm -f "$ERR"

  if grep -qE "$ARGV_RE" <<<"$LOG"; then
    echo "FAIL: the command override does not match this family's entry point"
    echo '  App family:       command ["db:migrate:status"] (the image entry point supplies rails)'
    echo '  migrate revision: command ["rake","db:migrate:status"] (entry point is bundle exec)'
    tr '\t' '\n' <<<"$LOG" | grep -iE "Unrecognized command" | head -3
    exit 1
  fi

  if grep -qE "$ERR_RE" <<<"$LOG"; then
    echo "FAIL: db:migrate:status did not complete"
    tr '\t' '\n' <<<"$LOG" | grep -iE "aborted|error|Mysql2|Schema migrations" | head -10
    exit 1
  fi

  ROWS=$(tr '\t' '\n' <<<"$LOG" | grep -E "$ROW_RE")
  count=$(grep -c . <<<"$ROWS")
  [ -z "$ROWS" ] && count=0
  if [ "$count" -gt 0 ] && [ "$count" -eq "$prev_count" ]; then break; fi
  prev_count=$count
  sleep 10
done

if [ -z "$ROWS" ]; then
  echo "FAIL: no migration status rows found for ${STREAM} within the timeout"
  if [ -z "$LOG" ]; then
    echo "  the log group exists, so check the task actually started and logged"
  else
    echo "  the stream has output but no status table; check the command override matches"
    echo "  the family's entry point (see Reading the schema state in SKILL.md)"
  fi
  exit 1
fi

# "up" rows whose file is gone print as "********** NO FILE **********". They mean the
# database is ahead of the image, which is normal mid-rollback and never a migrate
# failure, so they are counted apart from the real up rows.
UP=$(grep -E "^[[:space:]]*up" <<<"$ROWS" | grep -vF "NO FILE")
DOWN=$(grep -E "^[[:space:]]*down" <<<"$ROWS")
NOFILE=$(grep -F "NO FILE" <<<"$ROWS")

n_up=$(grep -c . <<<"$UP"); [ -z "$UP" ] && n_up=0
n_down=$(grep -c . <<<"$DOWN"); [ -z "$DOWN" ] && n_down=0
n_nofile=$(grep -c . <<<"$NOFILE"); [ -z "$NOFILE" ] && n_nofile=0

echo "schema_migrations: ${n_up} applied, ${n_down} pending, ${n_nofile} recorded without a file"

status=0

if [ "$n_down" -gt 0 ]; then
  if [ "$MODE" = applied ]; then
    echo "FAIL: ${n_down} migration(s) still pending after the migrate task"
    status=1
  else
    echo "pending:"
  fi
  # Cap the listing. A stack that has never been migrated reports every migration as
  # pending, and five hundred lines would bury the summary above.
  head -20 <<<"$DOWN"
  [ "$n_down" -gt 20 ] && echo "  ... and $((n_down - 20)) more"
fi

if [ "$n_nofile" -gt 0 ]; then
  echo "WARN: ${n_nofile} version(s) recorded with no migration file in this image"
  echo "  expected while rolled back to an older image; otherwise the database is ahead"
  head -5 <<<"$NOFILE"
fi

for want in ${EXPECTED+"${EXPECTED[@]}"}; do
  # Anchor on the version column so a timestamp cannot match inside a migration name,
  # and so a short version cannot match a longer one as a prefix.
  row=$(grep -E "^[[:space:]]*(up|down)[[:space:]]+${want}([[:space:]]|$)" <<<"$ROWS")
  if [ -z "$row" ]; then
    # The applied list comes from the database but the *file* list comes from the image, so
    # a version can be absent simply because this task ran an older image. After migrating
    # that is a real failure; on a pre-flight read against the still-deployed old image it
    # is the expected answer for a migration the release is about to add.
    if [ "$MODE" = applied ]; then
      echo "FAIL: migration ${want} is not in this image's migration set at all"
      echo "  the task ran an image that predates it, or the version is wrong"
      status=1
    else
      echo "NOT IN IMAGE: ${want} (expected if this image predates the release)"
    fi
  elif grep -qE "^[[:space:]]*up" <<<"$row"; then
    echo "OK: ${want} is up"
  elif [ "$MODE" = applied ]; then
    echo "FAIL: ${want} is still down"
    status=1
  else
    echo "PENDING: ${want}"
  fi
done

if [ "$MODE" = applied ] && [ $status -eq 0 ]; then
  echo "OK: every migration in this image is applied"
fi
exit $status
