RailsPortal::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite.  You never need to work with it otherwise.  Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs.  Don't rely on the data there!
  config.cache_classes = true

  # Eager loads all registered config.eager_load_namespaces. This includes your application, engines, Rails frameworks, and any other registered namespace.
  config.eager_load = true  # normally false unless you use a tool that preloads your test environment

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.default_url_options = {:protocol => APP_CONFIG[:protocol], :host => APP_CONFIG[:host] }
  config.action_mailer.asset_host = APP_CONFIG[:protocol] + '://' + APP_CONFIG[:host]
  config.action_mailer.delivery_method = :test

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  # Turn this off if localizing
  config.i18n.default_locale = 'en'
  config.i18n.fallbacks = true

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  # Keep test order in same order as before Rails 5
  config.active_support.test_order = :sorted

  config.assets.compile = true

  LogConfig.configure(config, ENV['TEST_LOG_LEVEL'], 'WARN')
end
