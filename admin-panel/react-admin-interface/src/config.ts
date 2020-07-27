import * as queryString from "query-string"

const defaultPortal = process.env.REACT_APP_PORTAL_URL
const defaultOatuhClientName = process.env.REACT_APP_OATUH_CLIENT_NAME
const params = queryString.parse(window.location.search);

const GraphQlHost = process.env.REACT_APP_GRAPHQL_HOST

// Note your Portal connection must use https:
const PortalUrl = params.REACT_APP_PORTAL_URL || defaultPortal

const OauthClientName = params.OATUH_CLIENT_NAME
  ? (params.OATUH_CLIENT_NAME as string)
  : defaultOatuhClientName

const JwtUrl = `${PortalUrl}/api/v1/jwt/portal`
const OauthUrl = `${PortalUrl}/auth/oauth_authorize`
export const Config = { GraphQlHost, PortalUrl, OauthClientName, JwtUrl, OauthUrl }
