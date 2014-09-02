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

ENV['PORTAL_FEATURES'] ||= ''

# CORS_ORIGINS:
# Sets the allowed CORS origins to a specific whitelist. Requires ENV['PORTAL_FEATURES'] ||= 'allow_cors'
# ENV['CORS_ORIGINS']    ||= "concord.org"

# CORS_RESOURECES:
# Sets the allowed CORS resources to a specific route. Requires ENV['PORTAL_FEATURES'] ||= 'allow_cors'
# ENV['CORS_RESOURCES']  ||= "/xyz"`: 
