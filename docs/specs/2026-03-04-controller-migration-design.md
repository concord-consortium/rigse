# Controller Migration to `current_user` — Design

**Date:** 2026-03-04
**Status:** Implemented
**Implements:** Portal Authentication Unification Design, Next Step 1
**PR:** #1469

## Goal

Replace `check_for_auth_token` with Devise's `current_user` in four API controllers so they authenticate via any Devise strategy (session, bearer token, and future OIDC).

## Background

The four controllers currently call `check_for_auth_token` (defined in `API::APIController`) which manually parses Bearer tokens and returns a `[user, role]` tuple. However, none of these controllers use the `role` from the token — they all derive roles from the database (e.g., `user.portal_teacher`). This means we can switch to `current_user` without losing any functionality.

Research confirms:
- **Referer validation** is not a concern for these controllers (see `referer-validation-research.md`)
- **Status code changes** (400→401/403) won't break any callers (see `controller-migration-caller-research.md`)

## Design Decisions

1. **Use `before_action :require_api_user!`** — A custom guard defined in `API::APIController` that returns JSON 401 for unauthenticated requests using the existing `error()` helper. See "Why not `authenticate_user!`?" below.
2. **Drop the `role` variable entirely** — None of the four controllers use the `:learner`/`:teacher` values from the token tuple.
3. **Keep existing authorization logic unchanged** — Pundit policies and database-derived role checks remain as-is.

### Why not `authenticate_user!`?

The original design proposed Devise's built-in `authenticate_user!`. During implementation planning, we discovered that Devise's `authenticate_user!` delegates to `CustomFailure`, which redirects HTML-format requests instead of returning JSON errors. Since these API controllers don't declare `respond_to :json`, using `authenticate_user!` would cause redirects instead of JSON errors in tests and for non-JSON callers.

A custom `require_api_user!` method is safer and consistent with the existing `error()` JSON pattern used throughout `API::APIController`:

```ruby
def require_api_user!
  unless current_user
    error('You must be logged in to use this endpoint', 401)
  end
end
```

## Per-Controller Changes

### 1. `API::V1::BookmarksController`

- Add `before_action :require_api_user!`
- Replace private `check_auth` method with `authorize_class_teacher!` — a simpler helper that validates class ownership using `current_user.portal_teacher` (no `check_for_auth_token` call)
- Replace all `auth[:user]` references with `current_user`
- **Status code change:** Guest requests return 401 (was 400)

### 2. `API::V1::TeacherClassesController`

- Add `before_action :require_api_user!` and `before_action :require_teacher!`
- `require_teacher!` is a private method that returns 400 if `current_user.portal_teacher` is nil, replacing the teacher check from `auth_teacher`
- Replace all `auth[:user]` / `user` references with `current_user`
- Keep `verify_class_ownership` and `verify_teacher_class_ownership` helpers (they still use the error-hash pattern for class-level authorization, but now take `current_user` instead of `auth[:user]`)
- **Status code change:** Guest requests return 401 (was 400)

### 3. `API::V1::ExternalActivitiesController`

- Add `before_action :require_api_user!`
- Remove all three inline `begin; user, role = check_for_auth_token(params); rescue ... end` blocks
- In `create`, use `current_user` instead of `user` from token when setting `external_activity.user`
- In `update_by_url` and `update_basic`, the `user` variable was obtained but never used (Pundit uses `current_user` internally), so the blocks are simply removed
- **Status code change:** Guest requests return 401 (was 403)

### 4. `API::V1::OfferingsController`

- **No `before_action` added** — only `create_for_external_activity` used `check_for_auth_token`. Adding a global guard would change guest behavior for `show`, `index`, `update`, `update_student_metadata` from 403 (Pundit) to 401.
- Remove `check_for_auth_token` call from `create_for_external_activity` and use `current_user` directly
- Pundit's `authorize` still handles guest rejection (403) for this action
- **No status code change** — guest requests still return 403 via Pundit

## Status Code Summary

| Controller | Old guest status | New guest status |
|---|---|---|
| BookmarksController | 400 | 401 |
| TeacherClassesController | 400 | 401 |
| ExternalActivitiesController | 403 | 401 |
| OfferingsController (other actions) | 403 (unchanged) | 403 (unchanged) |

## What Does NOT Change

- Pundit authorization policies
- Business logic (class ownership checks, teacher validation, etc.)
- Other controllers or the `check_for_auth_token` method itself (still used elsewhere)
- Non-API controllers (`Portal::BookmarksController`, `Portal::OfferingsController`, etc.)
