# Client-less Grants Replacement — Research Findings

**Date:** 2026-02-26
**Status:** In Progress
**Related:** `portal-authentication-unification-design.md` Section 8 (Next Steps)

---

## Method

The design doc identifies exactly 2 creation sites for client-less grants (Section 2.1). Both create 3-minute tokens with a learner but no client:

1. `app/models/external_activity.rb:150` — launch tokens for external activities
2. `app/services/api/v1/create_collaboration.rb:82` — collaboration tokens

## Findings

The creation sites are confirmed. Both call `User#create_access_token_with_learner_valid_for` which creates an `AccessGrant` with `learner_id` but no `client_id`.

The tokens are passed to external runtimes as URL parameters (`?token=...`). The runtime sends them back as `Authorization: Bearer <token>` to call Portal APIs. For Option B (replacing with JWTs) to work, the runtimes must treat the token as opaque — they must not make assumptions about its format (e.g., length, character set, absence of dots).

### Runtimes receiving client-less tokens

Production query (`ExternalActivity.where(append_auth_token: true)`) returned these distinct hostnames:

| Hostname | Status | Needs verification? |
|---|---|---|
| **activity-player.concord.org** | Active | Yes — verified below |
| **collaborative-learning.concord.org** | Active | Yes — verified below |
| **geniventure.concord.org** | Active | Yes — verified below |
| activity-player-offline.concord.org | Inactive — last launch May 2021 | No — not in use |
| collabspace.concord.org | Replaced by collaborative-learning | No — OK to break |
| workspaces.concord.org | Replaced by collaborative-learning | No — OK to break |
| dataflow-app.concord.org | Inactive — modern version is inside collaborative-learning | No — OK to break |
| 127.0.0.1 / localhost | Dev/test only | No |
| nil | Missing URL | No |

### Runtime token handling verification

All three active runtimes treat the Portal bearer token as **fully opaque**:

**activity-player** (repo: `concord-consortium/activity-player`)
- Token extracted from `?token=` URL param via `queryValue("token")` — returns raw string
- Sent as `Authorization: Bearer ${rawToken}` to `api/v1/jwt/portal` — no transformation
- Variable is named `rawToken`, emphasizing it is used as-is
- Never parsed, decoded, or inspected — only truthiness check (`if (bearerToken)`)
- After exchange for a Portal JWT, the original token is never used again
- Test mocks use simple strings like `"goodStudentToken"` — confirming no format assumptions

**collaborative-learning** (repo: `concord-consortium/collaborative-learning`)
- Token extracted from `?token=` URL param via `queryValue("token")` — returns raw string
- Stored as `this.bearerToken` (plain `string` property on the `Portal` class)
- Sent as `Authorization: Bearer ${bearerToken}` to `api/v1/jwt/portal`
- Never parsed, decoded, or inspected
- After exchange, the token is removed from the URL via `convertURLToOAuth2()` and replaced with OAuth2 parameters
- Test mocks use simple strings like `"goodStudentToken"` — confirming no format assumptions

**geniventure** (repo: `concord-consortium/geniblocks`)
- Token extracted from `?token=` URL param via generic query string parser into `urlParams.token`
- Sent as `Authorization: Bearer ${urlParams.token}` to `api/v1/jwt/firebase`
- Never parsed, decoded, or inspected
- After exchange, the token is stripped from the URL via `updateUrlParameter("token")`
- The `jwt.decode()` call in the codebase is applied to the Firebase JWT **response**, not the input bearer token

## Conclusion

**Option B (replacing client-less grants with JWTs) is viable.** All three active runtimes treat the bearer token as an opaque string. They extract it from the URL, send it verbatim in an `Authorization: Bearer` header, and never inspect its format. Changing the token from an AccessGrant token to a short-lived JWT would not require any changes to these runtimes.

## Open Questions

1. **Test locally** by launching from a local Portal with a JWT token instead of an AccessGrant token, to verify the end-to-end flow works.
