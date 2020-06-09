import * as queryString from "query-string"

const params = queryString.parse(window.location.search);

// Note your Portal connection must use https:
const PortalUrl = params.PORTAL_URL || "https://app.portal.docker"

const OauthClientName = (params.OATUH_CLIENT_NAME as string) || "admin-panel"

const JwtUrl = `${PortalUrl}/api/v1/jwt/portal`
const OauthUrl = `${PortalUrl}/auth/oauth_authorize`
export const Config = {PortalUrl, OauthClientName, JwtUrl, OauthUrl }
