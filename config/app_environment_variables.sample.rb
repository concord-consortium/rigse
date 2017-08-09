# configure the application using defaults, or ENV overrides.
# On servers this file will be generated & maintained by littlchef.
# ENV['PORTAL_FEATURES'] : enable / disable portal extension features. Here are some such features:
#
# `geniverse_remote_auth`: Remote authentication
# `allow_cors`: Allow CORS requests (see below)
# `genigames_data`: Genigames-related student sata saving
# `geniverse_wordpress`: Geniverse-related Wordpress connection
#
# sample :  ENV['PORTAL_FEATURES']  ||= 'geniverse_remote_auth genigames_data'
# EG, enable genigame auth / data via `     ENV['PORTAL_FEATURES']  ||= 'geniverse_remote_auth genigames_data'

ENV['PORTAL_FEATURES']   ||= ''
ENV['REPORT_VIEW_URL']   ||= 'https://concord-consortium.github.io/portal-report/'
ENV['REPORT_DOMAINS']    ||= '*.concord.org concord-consortium.github.io'

# Researcher report link can point to a different portal instance to avoid overloading the main server.
# ENV['RESEARCHER_REPORT_HOST'] ||= 'https://research-report-portal.concord.org'
# Portal that is dedicated to the research report should enable option below to disable all the links that could
# lead researchers to other parts of the portal.
# ENV['RESEARCHER_REPORT_ONLY'] ||= 'true'

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

# PORTAL_PAGES_LIBRARY_URL
#
# Path to portal-pages "library" dir containing
# portal-pages.js and portal-pages.css
# E.g. PORTAL_PAGES_LIBRARY_URL=http://localhost:10000/library
#

# EXTERNAL_CSS_URL
#
# Full path to site-redesign.css
# E.g. EXTERNAL_CSS_URL=http://localhost:10000/site-redesign/site-redesign.css
#

# GOOGLE_ANALYTICS_ACCOUNT
#
# Key for the GA account.

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


