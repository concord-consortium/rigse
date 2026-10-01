# Token Capabilities

What a portal token may do, and how the portal enforces it. Every new endpoint and every new client follows these conventions. How each kind of app connects to the portal and obtains its token is in [external-services.md](external-services.md); the history of the portal's authentication paths and how they are being merged is in [portal-authentication-unification-design.md](portal-authentication-unification-design.md).

## The convention

A token may carry a `scope` claim: a space-separated list of capabilities (RFC 6749 §3.3) from the registry in `lib/token_capabilities.rb`.

| Capability | Bound to a context | Accepted by | What it allows |
|---|---|---|---|
| `class:researcher-read` | class | rigse | Researcher reads of one class, such as the researcher Firebase token from `jwt/firebase` |
| `class:researcher-run` | class | rigse | Starting researcher work on one class |
| `packages:read` | no | report-server | Reading report-server's package catalog |
| `portal-api` | no | rigse | Any action under `API::APIController`; the scope of every service-minted token |

- **A token without `scope` is a full-user credential**, limited only by its user's permissions. Every token that predates the convention is one: HS256 portal JWTs, `AccessGrant` tokens and sessions. So is the unscoped access token `/oauth/token` gives a public client without scopes.
- **A token with `scope` is refused everywhere except on actions that declare one of its capabilities.**
- **A capability is a ceiling, never a grant.** An action that accepts a capability still runs its own authorization (Pundit, or a gate such as `can_be_researcher_for_clazz?`) exactly as it would for a caller with no scope. A token outlives a permission change it cannot be un-issued for, so the authorization runs on every call.
- **Capabilities are flat.** None implies another: a client that may run and read is configured with both.
- **`context`** binds a token to one object: `{"type": "class", "id": 123}`, where `id` is the portal's integer id (not report-service's class hash). A context-bound capability applies only to that object, and a scoped token without a context fails every context-bound check. The portal runs the capability's gate for the requesting user before it binds a context into a code at authorize.
- **Role is not scope.** A service-minted token's `scope` is `portal-api`; its `user_type`, `learner_id` and `teacher_id` claims are its role: who the token acts as, not where it may be used.

## Where it is enforced

- **One check for every controller.** `ApplicationController` runs `enforce_token_capabilities` (`TokenCapabilityCheck`) before every action. It reads the bearer itself, through `PortalBearer` and `TokenScope`, rather than asking Warden. Warden authenticates lazily, so a filter that waits for `current_user` sees nothing on an action that never touches it, and forcing authentication would store sessions where none were stored. Reading the bearer directly also keeps the ceiling when the request carries a session too, which Warden would otherwise prefer.
- **Declarations.** A controller declares what its actions accept with `accepts_token_capability` (with `only:`, `except:` and `if:`), and `accepts_no_token_capabilities` drops what a superclass declared. An action that checks a context-bound capability against a record calls `require_token_capability!(capability, record)`. `API::APIController` declares `portal-api` for every action. `JwtController` declares nothing, so no scoped token can re-mint itself as an unscoped one, except `class:researcher-read` on the researcher Firebase mint, which checks the requested class against the token's context.
- **One reader of the claims.** The Devise JWT strategy and `check_for_auth_token` apply a verified token's claims through the same `TokenScope.apply!` as the check, and all three read the Authorization header through `PortalBearer.raw_token`, so they cannot disagree about what a token may do.
- **No session.** The Devise JWT strategy stores no Rails session for a scoped token or for any RS256 access token. A scoped token cannot get one another way either, since `jwt/*` refuses it; an unscoped access token can still be exchanged at `jwt/portal` for an unscoped portal JWT, which does become a session (the D10 gap in the unification doc's Section 10).
- **No conversion.** No `AccessGrant` is created while the request's credential carries a scope, and a portal JWT minted during such a request inherits its `scope` and `context`.
- **Mounted engines** are not covered by `ApplicationController`'s filters. The one mounted today is session-authenticated and refuses bearer tokens, and `spec/routing/mounted_engines_spec.rb` fails if another engine is mounted.

## The tokens rigse issues

| Token | Issued by | Signed | `aud` | `scope` | Lifetime | Accepted as |
|---|---|---|---|---|---|---|
| Scoped access token | `/oauth/token`, to a client with scopes (code flow, with PKCE when public) | RS256, `typ: at+jwt` | a list: rigse's site URL, plus each other service whose capability it carries | the client's capabilities | `SignedJwt::SCOPED_ACCESS_TOKEN_TTL` | `Bearer` only |
| Unscoped access token | `/oauth/token`, to a public client without scopes (code flow with PKCE) | RS256, `typ: at+jwt` | a list naming rigse's site URL only | none | `SignedJwt::UNSCOPED_ACCESS_TOKEN_TTL` | `Bearer` only |
| Service-minted token | `POST /api/v1/jwt/oidc_mint` | HS256 | none | `portal-api` | `PortalTokenClaims::STANDARD_TTL` | `Bearer` or `Bearer/JWT` |
| Portal JWT | `jwt/portal`, resource launches, collaborations | HS256 | none | none, unless minted under a scoped token | `PortalTokenClaims::STANDARD_TTL` from `jwt/portal`; launch tokens are shorter | `Bearer` or `Bearer/JWT` |
| `AccessGrant` token | the implicit flow, the confidential code flow, report launches | opaque | none | none | `AccessGrant::ExpireTime`; `ExternalReport::ReportTokenValidFor` for report launches | `Bearer` |
| Service assertion | rigse, to report-server and the report-service function | RS256 | one string: `report-server` or `report-service-functions` | none | `PortalAssertions::TTL` | never accepted by rigse |

**Only the access tokens carry an `aud` list.** An access token has more than one recipient when it carries `packages:read`, so RFC 7519's array is its shape, and it never names an assertion's audience. Each assertion carries exactly one string, and every assertion verifier refuses a list, even one containing its own audience, because the `jwt` gem, `jsonwebtoken` and Joken all accept any list that contains the expected value. rigse accepts an RS256 token only when its header `typ` is `at+jwt` and its `aud` contains rigse's site URL, so an assertion authenticates no one here.

## Authorization schemes

`Bearer/JWT` is a portal-specific scheme that predates RFC 6750's `Bearer`. It was introduced to tell portal JWTs from opaque `AccessGrant` tokens, which content inspection now does: a JWT contains dots and an `AccessGrant` token never does. CLUE and the Activity Player still send `Bearer/JWT` with their HS256 portal JWTs, so it stays accepted for those tokens. It is not extended to anything new: the RS256 access tokens are accepted only as plain `Bearer`, and the long-term direction is for every portal token to use `Bearer`. The reasoning is in `docs/specs/2026-02-25-portal-oidc-authentication-design.md`, under "Why `Bearer` and not a custom scheme like `Bearer/OIDC`". The capability check reads both schemes, since refusing is always safe.

## Adding a capability

1. Add an entry to `TokenCapabilities::REGISTRY`: its name, the context type it is bound to (or nil), the service that accepts it (`:portal`, or another audience `audience_value` knows how to configure), and, when context-bound, the gate run at authorize.
2. A new context type also needs an entry in `TokenCapabilities::CONTEXT_TYPES` naming the record its `id` refers to.
3. Declare the capability on the actions that accept it, and call `require_token_capability!` with the record wherever the capability is context-bound.
4. Give the client that needs it the capability in its `scopes` on the admin client form. Changing a client's scopes cancels its pending codes.
