# ALB Access Logs — Design

**Date:** 2026-03-03
**Status:** Draft
**Related:** `2026-03-02-auth-launch-logging-design.md` (Change 4)

---

## Problem

Production has no HTTP-level visibility independent of Rails. When
investigating auth or launch issues, there are no ALB access logs to fall back
on — client IP, status code, request path, response time, and TLS version are
all invisible.

## Goal

Enable ALB access logs for the portal load balancer, writing to the existing
shared `concord-aws-logs` S3 bucket. Make it easy for other stacks (LARA, etc.)
to enable access logs in the future with no additional manual steps.

## Non-Goals

- Rails-level logging changes (covered separately in the parent design doc)
- Enabling access logs on other ALBs (future work, but the design supports it)

## Design

### Overview

Three changes across two repos plus one manual bucket policy update:

1. **Manual (one-time):** Add a generic bucket policy statement to
   `concord-aws-logs` allowing any ALB in the account to write under
   `alb-logs/`
2. **PR 1 — `cloud-formation`:** Add access log parameters to the shared
   `ecs-load-balancer.yml` nested template
3. **PR 2 — `rigse`:** Pass access log configuration from `stack_template.yml`
   to the nested template

### Manual: Bucket policy update (one-time)

Add a statement to the `concord-aws-logs` bucket policy:

```json
{
  "Effect": "Allow",
  "Principal": {
    "Service": "logdelivery.elasticloadbalancing.amazonaws.com"
  },
  "Action": "s3:PutObject",
  "Resource": "arn:aws:s3:::concord-aws-logs/alb-logs/*",
  "Condition": {
    "StringEquals": {
      "aws:SourceAccount": "612297603577"
    }
  }
}
```

This uses the AWS service principal (region-agnostic, newer recommended
approach) scoped to the account ID via condition. The `alb-logs/` prefix keeps
ALB logs isolated from the existing CloudTrail and LARA logs in the bucket.

After this one-time change, any ALB in the account can enable access logs by
configuring a sub-prefix under `alb-logs/` — no further bucket policy updates
needed.

### PR 1: `cloud-formation` — `ecs-load-balancer.yml`

Add 3 new parameters with backward-compatible defaults:

```yaml
AccessLogsS3Enabled:
  Type: String
  Default: "false"
  AllowedValues: ["true", "false"]
  Description: Enable ALB access logs to S3
AccessLogsS3Bucket:
  Type: String
  Default: ""
  Description: S3 bucket for ALB access logs
AccessLogsS3Prefix:
  Type: String
  Default: ""
  Description: S3 key prefix for ALB access logs
```

Append to the existing `LoadBalancerAttributes` on the `ELBv2` resource:

```yaml
- Key: access_logs.s3.enabled
  Value: !Ref AccessLogsS3Enabled
- !If
  - AccessLogsEnabled
  - Key: access_logs.s3.bucket
    Value: !Ref AccessLogsS3Bucket
  - !Ref "AWS::NoValue"
- !If
  - AccessLogsEnabled
  - Key: access_logs.s3.prefix
    Value: !Ref AccessLogsS3Prefix
  - !Ref "AWS::NoValue"
```

The `access_logs.s3.enabled` attribute is always emitted so that toggling from
`true` to `false` explicitly disables logging. The bucket and prefix are
conditionally omitted via `AWS::NoValue` when disabled, because CloudFormation
rejects an empty bucket value. All existing consumers (portal-ecs, lara-ecs,
portal-app-only, rigse internal ALB) keep working without changes.

### PR 2: `rigse` — `stack_template.yml`

**New parameters:**

```yaml
EnableALBAccessLogs:
  Type: String
  Default: "false"
  AllowedValues: ["true", "false"]
  Description: Enable ALB access logs to S3

ALBAccessLogsBucket:
  Type: String
  Default: concord-aws-logs
  Description: S3 bucket for ALB access logs
```

**New condition:**

```yaml
EnableALBAccessLogsCond:
  !Equals [!Ref EnableALBAccessLogs, "true"]
```

**Pass to `LoadBalancerStack`:**

```yaml
AccessLogsS3Enabled: !If [EnableALBAccessLogsCond, "true", "false"]
AccessLogsS3Bucket: !If [EnableALBAccessLogsCond, !Ref ALBAccessLogsBucket, ""]
AccessLogsS3Prefix: !Sub "alb-logs/${AWS::StackName}"
```

No new S3 resources — the existing `concord-aws-logs` bucket is reused.

### Log path structure

Logs will be written to:

```
s3://concord-aws-logs/alb-logs/<stack-name>/AWSLogs/612297603577/elasticloadbalancing/us-east-1/YYYY/MM/DD/
```

For example, `alb-logs/learn-ecs-production/` or `alb-logs/learn-portal-staging/`.
Each stack automatically gets its own sub-prefix based on its CloudFormation stack name.

### Log retention

The `concord-aws-logs` bucket does not currently have a lifecycle policy scoped
to the `alb-logs/` prefix. A 3-year (1095-day) expiration rule should be added
for `alb-logs/` to prevent unbounded growth. At ~59 GB/year (~$1.36/mo in S3
Standard), this caps storage at ~177 GB / ~$4/mo.

This can be added as a lifecycle rule on the bucket at the same time as the
policy update.

## Deployment Order

1. Update `concord-aws-logs` bucket policy (manual, one-time)
2. Add 3-year lifecycle rule for `alb-logs/` prefix (manual, one-time)
3. Deploy updated `ecs-load-balancer.yml` to S3 (PR 1)
4. Update rigse stack with `EnableALBAccessLogs=true` (PR 2)

Steps 1-2 are safe to do at any time — they have no effect until an ALB is
configured to write logs. Steps 3-4 are also safe with the default of
`EnableALBAccessLogs=false` — access logs are only enabled when the parameter
is explicitly set to `true`.

## Files Modified

| Repo | File | Change |
|------|------|--------|
| `cloud-formation` | `nested-templates/ecs-load-balancer.yml` | Add 3 access log parameters + LoadBalancerAttributes |
| `rigse` | `configs/cloudformation/stack_template.yml` | Add EnableALBAccessLogs param, condition, pass to nested template |

## Testing

- Verify the nested template change doesn't break existing stacks (deploy with
  defaults, confirm no diff)
- Enable access logs on staging and verify logs appear in
  `s3://concord-aws-logs/alb-logs/learn-portal-staging/`
- Confirm log entries contain expected fields (client IP, status code, request
  path, response time)
