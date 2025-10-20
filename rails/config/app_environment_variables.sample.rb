# configure the application using defaults, or ENV overrides.
# On servers this file will be generated & maintained by littlchef.
# ENV['PORTAL_FEATURES'] : enable / disable portal extension features. Here are some such features:
#
# `allow_cors`: Allow CORS requests (see below)
#
# sample :  ENV['PORTAL_FEATURES']  ||= 'allow_cors'

ENV['PORTAL_FEATURES']   ||= ''

# LOGGER_URI:
# Log manager logging endpoint
# ENV['LOGGER_URI'] ||= 'https://logger.concord.org/logs'    # production
# ENV['LOGGER_URI'] ||= 'https://logger.concordqa.org/logs'  # staging / development

# REPORT_SERVER_REPORTS_URL:
# URL for the report server reports used in the sidebar
# ENV['REPORT_SERVER_REPORTS_URL'] ||= 'https://report-server.concord.org/reports'

# CORS_ORIGINS:
# Sets the allowed CORS origins to a specific whitelist. Requires ENV['PORTAL_FEATURES'] ||= 'allow_cors'
# ENV['CORS_ORIGINS']    ||= "concord.org"

# CORS_RESOURCES:
# Sets the allowed CORS resources to a specific route. Requires ENV['PORTAL_FEATURES'] ||= 'allow_cors'
# ENV['CORS_RESOURCES']  ||= "/xyz"

# JWT_HMAC_SECRET:
# Sets the secret used to generate the portal JWT tokens in lib/signed_jwt.rb
# This the input to the SHA-256 HMAC so the max secret length should be 32 bytes (longer secrets are first hashed to 32 bytes)
# This can be generated in the Rails console via `SecureRandom.random_bytes(32)`
# ENV['JWT_HMAC_SECRET']  ||= "<32 bytes of random characters>"

# ASN_API_KEY
#
# A key for using the ASN standards service API.
# See http://asn.jesandco.org/
# See http://toolkit.asn.desire2learn.com/documentation/asn-search
#

# EXTERNAL_CSS_URL
#
# Full path to site-redesign.css
# E.g. EXTERNAL_CSS_URL=http://localhost:10000/site-redesign/site-redesign.css
#

# GOOGLE_ANALYTICS_MEASUREMENT_ID
#
# Key for the GA measurement ID.

# SCHOOLOGY_CONSUMER_KEY
# SCHOOLOGY_CONSUMER_SECRET
#
# Schoology key and secret for Schoology SSO oauth.
#

# GOOGLE_CLIENT_KEY
# GOOGLE_CLIENT_SECRET
#
# Google key and secret for Google SSO oauth.
#
