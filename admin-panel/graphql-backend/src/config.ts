import * as dotenv from "dotenv"
import { Request } from "express"

// reads ./.env and inserts into process.env
dotenv.config()

const jwtSecret = process.env.JWT_HMAC_SECRET;
const jwtUrl =  process.env.PORTAL_JWT_URL;

const jwtConfig = {
  secret: jwtSecret || "",
  // We need to be able to get the schema without credentials:
  credentialsRequired: false,
  getToken: function fromHeaderOrQuerystring (req: Request) {
    if (req.headers.authorization && req.headers.authorization.split(' ')[0] === 'Bearer') {
        return req.headers.authorization.split(' ')[1];
    } else if (req.query && req.query.token) {
      return req.query.token;
    }
    return null;
  }
}

export const Config = { jwtConfig, jwtSecret, jwtUrl }

