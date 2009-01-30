# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

# Restful Authentication
REST_AUTH_SITE_KEY = '115d54d0-ec9b-11dd-bad2-001ff3caa767'
REST_AUTH_DIGEST_STRETCHES = 10

# textmate-footnotes
# Rails errors displayed in browser are generated with links to textmate
# see: http://wiki.github.com/josevalim/rails-footnotes
config.gem "josevalim-rails-footnotes",  :lib => "rails-footnotes", :source => "http://gems.github.com"