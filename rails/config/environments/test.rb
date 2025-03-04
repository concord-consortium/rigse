require_relative "../../lib/log_config"

RailsPortal::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite.  You never need to work with it otherwise.  Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs.  Don't rely on the data there!
  config.cache_classes = false

  # Eager loads all registered config.eager_load_namespaces. This includes your application, engines, Rails frameworks, and any other registered namespace.
  config.eager_load = false  # normally false unless you use a tool that preloads your test environment

  # this will fall back to autoloading to files outside the app folder
  config.enable_dependency_loading = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = :none

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

  # START OF RAILS 5 OPTIONS
  #
  # The following are new Rails 5 config options with their default option set
  # We may want to change these options in the future.  More info here:
  #
  # https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#new-framework-defaults
  #
  config.active_record.belongs_to_required_by_default = false
  config.action_controller.per_form_csrf_tokens = false
  config.action_controller.forgery_protection_origin_check = false
  config.action_mailer.perform_caching = false
  config.ssl_options = { hsts: { subdomains: false } }
  # The following are commented out due to different reasons
  # 1. We don't want to rename the queue
  # config.action_mailer.deliver_later_queue_name = :new_queue_name
  # 2. This only is valid for PostgreSQL
  # config.active_record.dump_schemas = :all
  # 3. Commented out because this needs Ruby 2.4 to work
  # ActiveSupport.to_time_preserves_timezone = false
  #
  # END OF RAILS 5 OPTIONS

  # Rails 5 defaults to disable submit
  config.action_view.automatically_disable_submit_tag = false

  config.active_storage.service = :test

  LogConfig.configure(config, ENV['TEST_LOG_LEVEL'], 'WARN')
end
