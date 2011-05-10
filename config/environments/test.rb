# Settings specified here will take precedence over those in config/environment.rb
puts "loading test environment"
# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!

# enable this to block all requests which is useful to track down unnecessary ones
# require 'fakeweb'
# FakeWeb.allow_net_connect = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

config.cache_classes = false

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# Tell Action Mailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test
config.action_mailer.perform_deliveries = true
# current customizations below this line ...

unless RUBY_PLATFORM =~ /java/
  # Debugger.wait_connection = true
  # Debugger.stop_on_connect = true
  # Debugger.start_remote
  require 'ruby-debug'
  Debugger.start
  Debugger.settings[:autolist] = 1
  Debugger.settings[:autoeval] = 1
  Debugger.settings[:reload_source_on_change] = 1
end
