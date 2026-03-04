# Controller Migration to `current_user` — Design

**Date:** 2026-03-04
**Status:** Approved
**Implements:** Portal Authentication Unification Design, Next Step 1

## Goal

Replace `check_for_auth_token` with Devise's `current_user` in four API controllers so they authenticate via any Devise strategy (session, bearer token, and future OIDC).

## Background

The four controllers currently call `check_for_auth_token` (defined in `API::APIController`) which manually parses Bearer tokens and returns a `[user, role]` tuple. However, none of these controllers use the `role` from the token — they all derive roles from the database (e.g., `user.portal_teacher`). This means we can switch to `current_user` without losing any functionality.

Research confirms:
- **Referer validation** is not a concern for these controllers (see `referer-validation-research.md`)
- **Status code changes** (400→401/403) won't break any callers (see `controller-migration-caller-research.md`)

## Design Decisions

1. **Use `before_action :authenticate_user!`** — Devise's built-in guard rejects unauthenticated requests with 401, replacing inline `check_for_auth_token` error handling.
2. **Drop the `role` variable entirely** — None of the four controllers use the `:learner`/`:teacher` values from the token tuple.
3. **Keep existing authorization logic unchanged** — Pundit policies and database-derived role checks remain as-is.

## Per-Controller Changes

### 1. `API::V1::BookmarksController`

- Add `before_action :authenticate_user!`
- Replace private `check_auth` method with a simpler helper that validates class ownership using `current_user.portal_teacher`
- Remove `check_for_auth_token` call and `[user, role]` destructuring

### 2. `API::V1::TeacherClassesController`

- Add `before_action :authenticate_user!`
- Replace `auth_teacher(params)` calls with direct `current_user` / `current_user.portal_teacher` usage
- Remove error-hash pattern (`auth[:error]`)

### 3. `API::V1::ExternalActivitiesController`

- Add `before_action :authenticate_user!`
- Replace inline `check_for_auth_token` calls with `current_user` in `create`, `update_by_url`, and `update_basic`
- In `create`, use `current_user` instead of `user` from token when setting `external_activity.user`

### 4. `API::V1::OfferingsController`

- Add `before_action :authenticate_user!, only: [:create_for_external_activity]`
- Replace `check_for_auth_token` with `current_user` in `create_for_external_activity`
- Other actions already use `current_user` directly

## What Does NOT Change

- Pundit authorization policies
- Business logic (class ownership checks, teacher validation, etc.)
- Other controllers or the `check_for_auth_token` method itself (still used elsewhere)
- Non-API controllers (`Portal::BookmarksController`, `Portal::OfferingsController`, etc.)
