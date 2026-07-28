#!/usr/bin/env bash
# Verify the portal is consistently serving an expected version.
#
# During an ECS rolling deploy the load balancer serves both the old and new task
# generations, so the footer version flaps. A single request is not evidence: in a
# real deploy the new version appeared in 4 of 10 consecutive requests while half
# of all traffic was still on the old code. Require a run of agreeing responses.
#
# usage: check-deployed-version.sh <host> <expected-version> [streak] [max-seconds]
#   expected-version is the git tag WITH the v prefix, e.g. v2.30.0-pre.0
set -uo pipefail

HOST="$1"; EXPECTED="$2"; NEED="${3:-10}"; MAX="${4:-900}"
DEADLINE=$((SECONDS + MAX))
streak=0; last=""

echo "checking https://${HOST}/ for ${EXPECTED} (need ${NEED} consecutive)"
while [ $SECONDS -lt $DEADLINE ]; do
  v=$(curl -s --max-time 15 "https://${HOST}/" | grep -A1 -i '^Version:' | tail -1 | tr -d '[:space:]')
  if [ -z "$v" ]; then
    echo "  no version found in footer (request failed or markup changed)"
    streak=0
  elif [ "$v" = "$EXPECTED" ]; then
    streak=$((streak + 1))
  else
    [ "$v" != "$last" ] && echo "  serving $v (still rolling)"
    streak=0
  fi
  last="$v"
  if [ $streak -ge $NEED ]; then
    echo "OK: ${NEED} consecutive responses report ${EXPECTED}"
    exit 0
  fi
  sleep 5
done

echo "FAIL: did not reach ${NEED} consecutive responses reporting ${EXPECTED} within ${MAX}s (last saw '${last}')"
exit 1
