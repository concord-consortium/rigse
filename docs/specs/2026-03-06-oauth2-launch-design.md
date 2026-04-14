# OAuth2 Launch Support for ExternalActivities

**Date:** 2026-03-06
**Status:** Approved
**Related:**
- `2026-03-06-oauth2-launch-parameter-research.md` (parameter naming research)
- `2026-03-06-tool-usage-research.md` (LARA tool and logging queries)
- `../portal-authentication-unification-design.md` Section 9 Next Steps, Step 3

---

## Purpose

Add OAuth2 launch support to ExternalActivities as Step 3 of the auth unification design. Instead of minting a short-lived JWT and passing it as a `token` parameter, the Portal generates a launch URL with OAuth2 initialization parameters. The SPA handles authentication via the OAuth2 implicit grant redirect on first load.

This covers assignment launches only. Collaboration launches and report launches are out of scope.

---

## Design Decisions

### 1. Parameter names: `authDomain`, `resourceLinkId`, and `loginHint`

Per the team's prior decision to use camelCase for URL parameters (see launch parameter research doc, Section 3), and following CLUE's existing convention:

| Parameter | Value | Purpose |
|---|---|---|
| `authDomain` | Portal root URL | Portal URL for OAuth2 authorization |
| `resourceLinkId` | `learner.offering.id` | Offering ID, passed to Portal when requesting JWTs |
| `loginHint` | `learner.user.id` | Expected user ID; SPA forwards to Portal as `login_hint` for identity verification |

Content-specific parameters (e.g., `activity`, `unit`, `problem`) are already part of the ExternalActivity's base URL and are not affected.

**Naming convention note:** `loginHint` (camelCase) is the client-facing URL parameter name, following the team convention. The SPA forwards it to the Portal's `oauth_authorize` endpoint as `login_hint` (snake_case), following the OIDC convention for authorization endpoint parameters.

### 2. Configuration lives on the Tool model

A new `launch_method` string column on the Tool model controls how the Portal launches activities associated with that Tool.

| Value | Behavior |
|---|---|
| `nil` | Legacy behavior: use the ExternalActivity's own flags (`append_auth_token`, `append_learner_id_to_url`, `append_survey_monkey_uid`) |
| `"oauth2"` | Tool controls launch: append `authDomain`, `resourceLinkId`, and `loginHint`; ExternalActivity flags are ignored |

**Rationale:** All activities for a given runtime (e.g., all Activity Player activities) should launch the same way. The Tool model is the right level of abstraction for this — it represents the runtime platform. Per-activity flags are a legacy pattern; the long-term direction is to move shared settings up to the Tool.

### 3. Collaboration launches are deferred

OAuth2 launch URLs are reloadable and bookmarkable — that's a key feature. But collaboration launches are ephemeral: users should choose group members each time they launch. Putting `collaborators_data_url` in a persistent OAuth2 launch URL would lock users into a specific collaboration group on reload or bookmark.

Collaboration launches continue using the current JWT token approach (`create_collaboration.rb`). A separate design is needed to reconcile the reloadable URL model with ephemeral group selection.

---

## Data Model Changes

### Tool model: new `launch_method` column

```ruby
# Migration
add_column :tools, :launch_method, :string, default: nil
```

- Nullable string, default `nil`
- Exposed in the admin Tools form as a select dropdown
- Added to `tool_strong_params` in `Admin::ToolsController`

### No changes to ExternalActivity model

The existing `append_auth_token`, `append_learner_id_to_url`, and `append_survey_monkey_uid` flags continue to work when `tool.launch_method` is `nil`.

### Default report safety

Creating new Tools (e.g., source_type: "CLUE") is safe. `DefaultReportService` matches `tool.source_type` against `ExternalReport.default_report_for_source_type`. No ExternalReport has `default_report_for_source_type` set to "CLUE", so no surprise report buttons will appear. If a test Tool reuses an existing source_type (e.g., "ActivityPlayer"), it inherits the same default report — which is the desired behavior for testing.

---

## Launch URL Generation

### Where the change happens

`external_activity.rb#url` method (currently lines 142-158).

### Current behavior

```ruby
def url(learner = nil, domain = nil)
  uri = URI.parse(read_attribute(:url))
  if learner
    append_query(uri, "learner=#{learner.id}") if append_learner_id_to_url
    append_query(uri, "c=#{learner.user.id}") if append_survey_monkey_uid
    if append_auth_token
      token = SignedJwt::create_portal_token(learner.user, {learner_id: learner.id, user_type: "learner"}, 180)
      append_query(uri, "token=#{token}")
      append_query(uri, "domain=#{domain}&domain_uid=#{learner.user.id}") if domain
    end
  end
  return uri.to_s
end
```

### New behavior

Before checking the ExternalActivity's own flags, check `self.tool&.launch_method`. If it's `"oauth2"`, append OAuth2 parameters and return early:

```ruby
def url(learner = nil, domain = nil)
  uri = URI.parse(read_attribute(:url))
  if learner
    if self.tool&.launch_method == "oauth2"
      append_query(uri, "authDomain=#{domain}") if domain
      append_query(uri, "resourceLinkId=#{learner.offering.id}")
      append_query(uri, "loginHint=#{learner.user.id}")
      return uri.to_s
    end

    append_query(uri, "learner=#{learner.id}") if append_learner_id_to_url
    # ... existing flag-based logic unchanged ...
  end
  return uri.to_s
end
```

The `offering.id` is accessed via `learner.offering` — each learner record belongs to a specific offering.

---

## login_hint Identity Verification

### Problem

OAuth2 launches are reloadable — the URL persists in the browser. If a user has two tabs open and logs out in one tab, then logs in as a different user, the stale tab's launch URL will silently authenticate as the wrong user when clicked. The SPA would get a valid token for the wrong person.

### Solution

The Portal includes a `loginHint` parameter in the launch URL containing the expected user's ID. The SPA forwards this to the Portal's `oauth_authorize` endpoint as `login_hint`. The Portal checks it against the currently logged-in user.

### Flow

1. Portal generates launch URL with `loginHint={user_id}`
2. SPA redirects to `/auth/oauth_authorize?...&login_hint={user_id}`
3. Portal's `oauth_authorize` checks:
   - **No `login_hint`** → existing behavior (auto-redirect if logged in, login page if not)
   - **`login_hint` matches `current_user.id`** → proceed normally
   - **`login_hint` doesn't match `current_user.id`** → render warning page
   - **User not logged in** → show login page (existing behavior); `login_hint` is preserved in `after_sign_in_path` so the check happens after login

### Warning page

The warning page displays:

> You are currently logged in as **{current_user.name}**. The application expected a different user.
>
> [Continue as {current_user.name}]  [Log in as a different user]

- **"Continue"** → redirects to `oauth_authorize` with the same params minus `login_hint`; proceeds with normal OAuth2 flow
- **"Log in as a different user"** → logs out the current user, redirects to login page with `after_sign_in_path` set to the `oauth_authorize` URL without `login_hint`; after login, proceeds normally

This is a **one-shot check**: once the user takes either action, `login_hint` is removed from the flow.

### Security considerations

- The warning page does NOT reveal any information about the hinted user — no name, no email, no confirmation of whether the ID exists. It only shows the currently logged-in user's name (which they already know).
- The `loginHint` value is the user's numeric ID. Even if someone guesses random IDs, the warning page reveals nothing about the hinted user.
- `loginHint` is advisory, not authoritative. Clients must NOT use it to determine the user's identity. After OAuth2 completes, the client gets the actual user identity from the Portal JWT.

### Implementation

- Small addition to `oauth_authorize` in `auth_controller.rb`
- New view template: `auth/login_hint_mismatch.html.haml`
- New controller action to handle the "Continue" and "Log in as a different user" buttons

### Offerings controller: no changes needed

The non-LARA branch in `offerings_controller.rb` (line 72) already delegates to `external_activity.rb#url`. The controller doesn't need to know about OAuth2 launch.

The LARA branch (lines 52-71) is likely dead code (pending production query confirmation in `2026-03-06-tool-usage-research.md`). Its removal is independent of this design.

---

## Testing Strategy

### Unit tests

- `external_activity.rb#url` with `tool.launch_method == "oauth2"`: verify it appends `authDomain`, `resourceLinkId`, and `loginHint`; does NOT append `token`, `domain`, or `domain_uid`
- `external_activity.rb#url` with `tool.launch_method == nil`: verify existing behavior unchanged (respects ExternalActivity flags)
- `external_activity.rb#url` with no Tool: verify existing behavior unchanged
- Verify `authDomain` uses the portal root URL, `resourceLinkId` uses `learner.offering.id`, and `loginHint` uses `learner.user.id`

### Controller tests for login_hint

- `oauth_authorize` with no `login_hint`: existing behavior (auto-redirect)
- `oauth_authorize` with `login_hint` matching `current_user.id`: proceeds normally
- `oauth_authorize` with `login_hint` not matching `current_user.id`: renders warning page
- `oauth_authorize` with `login_hint` when user not logged in: shows login page with `login_hint` preserved in `after_sign_in_path`
- Warning page "Continue" action: redirects to `oauth_authorize` without `login_hint`
- Warning page "Log in as a different user" action: logs out and redirects to login

### Admin UI

- Verify `launch_method` field appears in Tool admin form and can be set/cleared

### Manual integration testing

1. Create a test Tool with `launch_method: "oauth2"` via admin UI (e.g., "ActivityPlayer-OAuth2")
2. Assign a few test ExternalActivities to it
3. Launch as a student — verify the launch URL contains `authDomain` and `resourceLinkId` (and NOT `token`)
4. Verify the client handles the OAuth2 flow correctly (requires client-side Step 4 to be done first)

---

## Documentation Updates

### `docs/portal-authentication-unification-design.md`

- Update Step 3 in Section 9 (Next Steps) to note that collaboration launches are deferred
- Add a note explaining the tension: OAuth2 launch URLs are reloadable/bookmarkable, but collaborations want fresh group selection on each launch

### `docs/external-services.md`

- Update the "SPA OAuth2 initialization pattern" section to reference `authDomain` and `resourceLinkId` as the Portal's standard parameter names
- Add a note in the collaboration section that collaboration launches are not yet migrated to OAuth2

---

## Out of Scope / Future Steps

- **Collaboration launches** — need separate design to reconcile reloadable URLs with ephemeral group selection
- **Report launches** — remain on AccessGrant tokens; different parameter set and auth flow (Step 5 of unification design)
- **LARA launch path removal** — pending production query results; independent cleanup
- **Client-side changes** — Step 4 of unification design; clients must be updated before flipping any Tool to `"oauth2"`
- **Moving ExternalActivity flags to Tool** — natural follow-on once every ExternalActivity has a Tool (`append_learner_id_to_url`, `append_survey_monkey_uid`, `append_auth_token` would move up to Tool)
- **Creating Tools for all ExternalActivities** — future step already noted in `docs/external-services.md` "Ways to Improve"
