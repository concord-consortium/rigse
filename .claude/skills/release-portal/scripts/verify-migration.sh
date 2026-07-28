#!/usr/bin/env bash
# Verify a rigse migration task actually applied its migrations, by reading the
# Rails output from CloudWatch. The log stream can lag the task by up to a minute,
# so poll rather than read once.
#
# usage: verify-migration.sh <log-group> <task-id> [expected-migration-class ...]
#
# Reads a single page of log events (1MB / 10k cap). That has been ample for real
# runs; if a release ever migrates enough to exceed it, follow nextForwardToken.
set -uo pipefail

GROUP="$1"; TASK_ID="$2"; shift 2
EXPECTED=("$@")
STREAM="portal/App/${TASK_ID}"
DEADLINE=$((SECONDS + 300))
GRACE=30

# Match only definitive markers. A bare "ActiveRecord::" would also match routine
# deprecation warnings and break the poll while the stream is still filling, which
# then fails the assertions below against a partial log.
DONE_RE="migrated \(|rake aborted!|ActiveRecord::(StatementInvalid|NoDatabaseError)|Mysql2::Error"

echo "waiting for log stream ${STREAM} in ${GROUP}"
LOG=""; first_seen=0
while [ $SECONDS -lt $DEADLINE ]; do
  LOG=$(aws logs get-log-events --log-group-name "$GROUP" --log-stream-name "$STREAM" \
        --start-from-head --query 'events[].message' --output text 2>/dev/null) || LOG=""
  if grep -qE "$DONE_RE" <<<"$LOG"; then break; fi
  # A no-op run prints neither a migration nor an error, so once the stream exists
  # give it a short grace period instead of burning the whole deadline.
  if [ -n "$LOG" ]; then
    [ $first_seen -eq 0 ] && first_seen=$SECONDS
    [ $((SECONDS - first_seen)) -ge $GRACE ] && break
  fi
  sleep 10
done

if [ -z "$LOG" ]; then
  echo "FAIL: no log events found for ${STREAM} within the timeout"; exit 1
fi

if grep -qE "rake aborted!|ActiveRecord::(StatementInvalid|NoDatabaseError)|Mysql2::Error" <<<"$LOG"; then
  echo "FAIL: migration log contains an error"
  tr '\t' '\n' <<<"$LOG" | grep -iE "aborted|error|Mysql2" | head -10
  exit 1
fi

# Class names routinely contain digits (AddS3FieldsToUsers), so the name character
# class must not be alphabetic-only or those migrations vanish from this list while
# the per-class assertions below still pass.
APPLIED=$(tr '\t' '\n' <<<"$LOG" | grep -oE "== [0-9]+ [A-Za-z0-9_]+: migrated" | awk '{print $3}' | tr -d ':')
if [ -z "$APPLIED" ]; then
  echo "WARN: no migrations were applied (schema already current?)"
else
  echo "applied: $(tr '\n' ' ' <<<"$APPLIED")"
fi

status=0
for want in "${EXPECTED[@]}"; do
  if grep -q "${want}: migrated" <<<"$LOG"; then
    echo "OK: ${want}"
  else
    echo "FAIL: expected migration ${want} not found in log"; status=1
  fi
done
exit $status
