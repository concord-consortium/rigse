# Send Email API

**Jira**: https://concord-consortium.atlassian.net/browse/RIGSE-334

**Status**: **Closed**

## Overview

Add a new Portal API endpoint that allows OIDC-authenticated services (e.g., Cloud Functions backing the button interactive) to send email notifications to the invoking user when a student completes an action like joining a class.

## Requirements

- `POST /api/v1/emails/oidc_send` accepts a JSON POST with `subject` (string) and `message` (string, plain text)
- The endpoint requires OIDC bearer token authentication — unauthenticated or non-OIDC requests are rejected
- OIDC-only access is enforced at two levels: a controller `before_action` guard that checks `request.env['portal.auth_strategy'] == 'oidc_bearer_token'`, and a Pundit policy that performs the same check (defense in depth)
- The email recipient is always the `current_user`'s email address (the OIDC invoker's mapped Portal user) — no recipient field is accepted in the request
- The sender address follows the existing pattern: `APP_CONFIG[:site_name] <APP_CONFIG[:help_email]>`
- The email is plain text only (no HTML rendering needed)
- Email is sent synchronously (matching existing mailer patterns)
- The endpoint returns a JSON success/failure response following existing API conventions
- Input validation: `subject` and `message` are required, non-empty strings (enforced by `params.require`, which rejects missing, nil, and blank values; no explicit length limits)
- The endpoint is restricted to OIDC-authenticated requests only (not accessible via session auth, Portal JWT, or AccessGrant tokens)
- The endpoint validates that `current_user.email` is present before attempting to send; returns a 422 JSON error if missing
- If the mailer raises an exception (SMTP timeout, connection refused, etc.), the endpoint rescues the error, logs it, and returns a JSON error response (502) including the error class and message (safe since this is an internal server-to-server API)
- The controller logs each email send (recipient, subject truncated to 80 characters, OIDC client name from `request.env['portal.auth_client']`) via `Rails.logger.info` for debugging and auditing

## Technical Notes

**Existing email infrastructure:**
- ActionMailer configured in `rails/config/initializers/actionmailer.rb`, SMTP settings from `rails/config/mailer.yml`
- Existing mailers: `Portal::ClazzMailer`, `UserMailer`, `PasswordMailer` — all extend `ActionMailer::Base` with `default :from` and `helper :theme`
- `Portal::ClazzMailer` pattern: sets instance variables, calls `mail()` with `:to`, `:subject`, `:date`

**OIDC authentication flow:**
- `OidcBearerTokenAuthenticatable` Devise strategy verifies Google-signed JWT, looks up `Admin::OidcClient` by `sub` claim, sets `current_user` to mapped user
- `request.env['portal.auth_strategy']` is set to `'oidc_bearer_token'` for OIDC requests
- The strategy sets `request.env['portal.auth_client']` with the client name

**API controller patterns:**
- Controllers inherit from `API::APIController`
- Use `current_user` from Devise for authentication
- `before_action :require_api_user!` ensures a logged-in user (any auth strategy)
- Pundit used for authorization — headless pattern: `authorize [:api, :v1, :email], :oidc_send?`
- Standard error responses via `error(status_code)` helper

**`before_action` ordering:**
- Declare `require_api_user!` before the OIDC-only guard — Devise strategies set `request.env['portal.auth_strategy']` during `current_user` access, so `current_user` must be resolved first.

**CSRF:**
- The controller needs `skip_before_action :verify_authenticity_token` since it's called by Cloud Functions (no Rails CSRF token). Safe because the endpoint rejects session-based auth entirely.

**Implementation safeguard:**
- Strip `\r` and `\n` from the subject before passing to ActionMailer as a belt-and-suspenders guard against header injection.

## Out of Scope

- HTML email rendering or rich-text formatting
- Sending emails to arbitrary recipients (not the invoker)
- Email templates with dynamic variables beyond subject/message
- Rate limiting (can be added later if needed)
- Delivery status tracking or receipts
- Attachment support
