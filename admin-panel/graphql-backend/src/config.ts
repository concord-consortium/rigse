import * as dotenv from "dotenv"

dotenv.config()

export const Config = {
  jwtSecret: process.env.JWT_HMAC_SECRET,
  jwtUrl: process.env.PORTAL_JWT_URL
}

