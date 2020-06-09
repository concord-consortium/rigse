import ClientOAuth2 from "client-oauth2";
import { Config } from "./config"
type anyForNow = any
type LoginParams = anyForNow
type CheckAuthParams = {jwt: JwtType}
type ErrorParams = string
type GetPermissionsParams = anyForNow
type JwtType = string|null

// TODO / TBD: -- We could ether use this variable, or localstorage
let currentJwt: JwtType = null

const getURLParam = (name: string) => {
  const url = window.location.href;
  name = name.replace(/[[]]/g, "\\$&");
  const regex = new RegExp(`${name}(=([^&#]*)|&|#|/|$)`);
  const results = regex.exec(url);
  if (!results) return null;
  return decodeURIComponent(results[2].replace(/\+/g, " "));
};

const resetHash = () => {
  window.history.pushState("",
  document.title, window.location.pathname
  + window.location.search);
}
export const authorizeInPortal = () => {
  const portalAuth = new ClientOAuth2({
    clientId: Config.OauthClientName,
    redirectUri: window.location.origin + window.location.pathname + window.location.search,
    authorizationUri: Config.OauthUrl
  });
  // Redirect
  window.location.href = portalAuth.token.getUri();
};

export const readPortalAccessToken = (): string => {
  // No error handling to keep the code minimal.
  return getURLParam("access_token") || "";
};

export const getPortalJWT = (portalAccessToken: string): Promise<string> => {
  const authHeader = { Authorization: `Bearer ${portalAccessToken}` };
  return fetch(Config.JwtUrl, { headers: authHeader })
    .then(response => response.json())
    .then(json => json.token)
}
const validateJwt = (jwt:string|null) => {
  return jwt && jwt.length > 1
}
const authProvider = {
    login: (params: LoginParams) => {
      console.log("login")
      return Promise.resolve()
    },
    logout: (params: LoginParams) => {
      console.log("logout")
      console.dir(params)
      return Promise.resolve()
    },
    checkAuth: async (params: CheckAuthParams) => {
      console.log("checkAuth")
      if(validateJwt(currentJwt)) return Promise.resolve()
      const token = readPortalAccessToken()
      if(token && token.length > 1) {
        const jwt = await getPortalJWT(token)
        if(validateJwt(jwt)) {
          currentJwt = jwt
          resetHash();
          return true
        }
      }
      return Promise.reject()
    },
    checkError: (error: ErrorParams) => {
      console.error(`auth error: ${error}`)
      return Promise.resolve()
    },
    getPermissions: (params: GetPermissionsParams) => {
      console.log("getPermissions")
      console.dir(params)
      return Promise.resolve()
    }
};

export {authProvider, currentJwt}