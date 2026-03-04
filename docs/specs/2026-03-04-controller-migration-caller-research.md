# Controller Migration Caller Research — Routes, Clients, and Error Handling

**Date:** 2026-03-04
**Status:** Complete
**Related:** `../portal-authentication-unification-design.md` Section 6 Step 1

---

## Purpose

Section 6 Step 1 of the auth unification design calls for migrating four controllers from `check_for_auth_token` to `current_user`. This changes the HTTP status code for authentication failures from **400** to **403** on some actions (the `error()` helper defaults to 400; Pundit returns 403).

This document inventories every affected route, identifies all callers (internal and external), and determines whether any caller depends on specific HTTP status codes or error messages.

---

## Method

1. **Route enumeration:** `docker compose run --rm app bundle exec rails routes` filtered for the four controllers
2. **Internal caller search:** `grep` across Portal React components, ERB templates, and JavaScript assets
3. **External caller search:** `gh search code` across the `concord-consortium` GitHub organization
4. **Error handling analysis:** Read caller source code to determine how API errors are processed

### Search reliability

All identified callers construct Portal API URLs using **full path string literals**, which means the `gh search code` queries for paths like `api/v1/bookmarks` reliably found all references:

- **Portal React** (`edit.tsx`): `const basePath = "/api/v1/bookmarks"`
- **Portal React** (`manage-classes.tsx`): `const teacherClassesBasePath = "/api/v1/teacher_classes"`
- **LARA** (`auth_portal.rb`): `APPublishingPath = "/api/v1/external_activities"` and `APRePublishingPath = "/api/v1/external_activities/update_by_url"`
- **CLUE** (`portal-api.ts`): `` `${domain}api/v1/offerings/create_for_external_activity` ``

No caller constructs these URLs by splitting the path into segments (e.g., `base + "bookmarks"`) that would evade a full-path search.

---

## 1. BookmarksController

All four actions use `check_for_auth_token` via the private `check_auth` helper.

### Routes

| Method | Path | Action |
|---|---|---|
| POST | `/api/v1/bookmarks` | `create` |
| PATCH/PUT | `/api/v1/bookmarks/:id` | `update` |
| DELETE | `/api/v1/bookmarks/:id` | `destroy` |
| POST | `/api/v1/bookmarks/sort` | `sort` |

### Current error behavior

Auth failures return **400** (default `error()` status). The `check_auth` helper catches `StandardError` from `check_for_auth_token` and returns `{error: e.message}`, which the action passes to `error(auth[:error])`.

### Callers

| Caller | Repo | File | Auth mechanism |
|---|---|---|---|
| Portal React | rigse (internal) | `react-components/src/library/components/bookmarks/edit.tsx` | Session cookies (jQuery AJAX, no `Authorization` header) |

**No external callers found.** GitHub org search for `api/v1/bookmarks` returned only rigse results.

### Error handling in caller

The React component uses jQuery AJAX with a generic error callback:

```javascript
error: (jqXHR, textStatus, error) => {
  reject(error);  // Passes through raw error string
}
```

The `showError` method displays `err.message` if present. **No status code checking.** The component does not differentiate between 400, 403, or any other error status.

### Impact of 400→403 change

**None.** The sole caller uses session cookies (not Bearer tokens), so auth failures from `check_for_auth_token` are only hit when the session is invalid. After migration to `current_user`, the session path is identical. The status code change is unobservable to this caller.

---

## 2. TeacherClassesController

All three actions use `check_for_auth_token` via the `auth_teacher` helper (which calls `auth_not_anonymous`, which calls `check_for_auth_token`).

### Routes

| Method | Path | Action |
|---|---|---|
| GET | `/api/v1/teacher_classes/:id` | `show` |
| POST | `/api/v1/teacher_classes/sort` | `sort` |
| POST | `/api/v1/teacher_classes/:id/copy` | `copy` |

### Current error behavior

Auth failures return **400** (default `error()` status). The `auth_teacher` helper returns `{error: e.message}` on auth failure, including "You must be logged in to use this endpoint" and "You must be logged in as a teacher to use this endpoint".

### Callers

| Caller | Repo | File | Auth mechanism |
|---|---|---|---|
| Portal React | rigse (internal) | `react-components/src/library/components/portal-classes/manage-classes.tsx` | Session cookies (jQuery AJAX, no `Authorization` header) |

**No external callers found.** GitHub org search for `api/v1/teacher_classes` returned only rigse results.

### Error handling in caller

```javascript
error: (jqXHR, textStatus, error) => {
  try {
    error = JSON.parse(jqXHR.responseText);
  } catch (e) {
    // noop - fall back to plain error
  }
  throw error;
}
```

Errors are caught by a `window.onerror`-style handler and displayed via `window.alert()`. **No status code checking.** The component parses the response body for a message but does not branch on the HTTP status.

### Impact of 400→403 change

**None.** Same reasoning as BookmarksController — session-only caller, status code not checked.

---

## 3. ExternalActivitiesController

Three actions use `check_for_auth_token` directly.

### Routes

| Method | Path | Action |
|---|---|---|
| POST | `/api/v1/external_activities` | `create` |
| POST | `/api/v1/external_activities/update_by_url` | `update_by_url` |
| POST | `/api/v1/external_activities/:id/update_basic` | `update_basic` |

### Current error behavior

- **`create`**: Auth failures return **400** (default `error()` status). Note: the `authorize` call runs *before* `check_for_auth_token`, so Pundit may return 403 first for unauthorized users.
- **`update_by_url`**: Auth failures return **403** (explicitly passed: `error(e.message, 403)`).
- **`update_basic`**: Auth failures return **403** (explicitly passed: `error(e.message, 403)`).

### Callers

| Caller | Repo | File | Auth mechanism | Endpoints called |
|---|---|---|---|---|
| LARA | concord-consortium/lara | `lib/concord/auth_portal.rb`, `app/models/publishable.rb` | Bearer token (`Authorization: Bearer <token>`) | `create`, `update_by_url` |

**`update_basic` has no known callers** — not in LARA, not in the Portal's own frontend, not in any other concord-consortium repo. It appears to be unused.

### Error handling in LARA

LARA's `portal_publish_with_token` method (in `publishable.rb`):

```ruby
response = HTTParty.post(url,
  body: json,
  headers: { "Authorization" => auth_token, "Content-Type" => "application/json" }
)

{
  response: response,
  success: response.code == success_code,  # 201 for create, 200 for update_by_url
  publication_data: json
}
```

**No status code differentiation for errors.** LARA checks `response.code == 201` (or 200) for success. Any other status code — whether 400, 403, 422, or 500 — results in `success: false`. The response is stored for debugging but the status code is not used for branching or retry logic.

### Impact of 400→403 change

- **`create`**: Auth failure changes from 400 to 403. LARA treats both as `success: false`. **No impact.**
- **`update_by_url`**: Already returns 403 for auth failures. **No change.**
- **`update_basic`**: Already returns 403 for auth failures, and has no known callers. **No impact.**

---

## 4. OfferingsController

Only `create_for_external_activity` uses `check_for_auth_token`. The other actions (`show`, `update`, `update_student_metadata`, `index`) already use `current_user` + Pundit and are not affected by this migration.

### Routes (affected action only)

| Method | Path | Action |
|---|---|---|
| POST | `/api/v1/offerings/create_for_external_activity` | `create_for_external_activity` |

### Current error behavior

Auth failures return **400** (default `error()` status): `return error(e.message)`.

### Callers

| Caller | Repo | File | Auth mechanism |
|---|---|---|---|
| CLUE Standalone | concord-consortium/collaborative-learning | `src/lib/portal-api.ts` | Portal JWT (`Authorization: Bearer/JWT <jwt>`) |

**No other external callers found.** Other repos reference `/api/v1/offerings` but only for `show`/`index`/`update` actions, which are not affected.

### Error handling in CLUE

CLUE's `createPortalOffering()` function (in `portal-api.ts`):

```typescript
superagent
  .post(`${domain}api/v1/offerings/create_for_external_activity`)
  .set("Authorization", `Bearer/JWT ${rawPortalJWT}`)
  .end((err, res) => {
    if (err) {
      reject(getErrorMessage(err, res));
    } else {
      resolve(res.body.id);
    }
  });
```

The `getErrorMessage` helper (in `super-agent-helpers.ts`):

```typescript
export const getErrorMessage = (err: any, res: superagent.Response) => {
  return (res && res.body ? res.body.message : null) || err;
};
```

**No status code checking.** Errors are rejected with the response body's `message` field (or the raw error object). The caller displays a generic error state in the UI. No branching on 400 vs 403.

### Impact of 400→403 change

**None.** CLUE does not check the status code. It extracts the error message from the response body, which may change text (e.g., from "You must be logged in..." to "Not authorized") but is only displayed as a generic error string.

---

## Summary

| Controller | Action | Current auth error status | Callers | Caller checks status code? |
|---|---|---|---|---|
| BookmarksController | create | 400 | Portal React (session) | No |
| BookmarksController | update | 400 | Portal React (session) | No |
| BookmarksController | destroy | 400 | Portal React (session) | No |
| BookmarksController | sort | 400 | Portal React (session) | No |
| TeacherClassesController | show | 400 | Portal React (session) | No |
| TeacherClassesController | sort | 400 | Portal React (session) | No |
| TeacherClassesController | copy | 400 | Portal React (session) | No |
| ExternalActivitiesController | create | 400 | LARA (Bearer token) | No — checks `== 201` only |
| ExternalActivitiesController | update_by_url | 403 (already) | LARA (Bearer token) | No — checks `== 200` only |
| ExternalActivitiesController | update_basic | 403 (already) | **None found** | N/A |
| OfferingsController | create_for_external_activity | 400 | CLUE (Portal JWT) | No |

### Conclusion

**Changing auth failure responses from 400 to 403 will not break any caller.** No caller in the concord-consortium organization checks for specific HTTP error status codes. All callers use generic error handling that treats any non-success response uniformly.

Additionally:
- BookmarksController and TeacherClassesController callers use **session cookies only**, so the Bearer token auth path in `check_for_auth_token` is never exercised for these endpoints.
- `ExternalActivitiesController#update_basic` appears to have **no callers** and may be dead code (though confirming this is out of scope for this document).
