require_relative "../../lib/log_config"

RailsPortal::Application.configure do
  # Edit at your own peril - it's recommended to regenerate this file
  # in the future when you upgrade to a newer version of Cucumber.

  # IMPORTANT: Setting config.cache_classes to false is known to
  # break Cucumber's use_transactional_fixtures method.
  # For more information see https://rspec.lighthouseapp.com/projects/16211/tickets/165
  config.cache_classes = true

  config.eager_load = true  # normally false unless you use a tool that preloads your test environment

  # this will fall back to autoloading to files outside the app folder
  config.enable_dependency_loading = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local        = true
  config.action_controller.perform_caching  = false

  # Disable request forgery protection in test environment
  # config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options = {:protocol => APP_CONFIG[:protocol], :host => APP_CONFIG[:host] }
  # All the gems required for testing are listed in: config/environments/test.rb
  #
  # Install the gems required for testing:
  #
  #   sudo env RAILS_ENV=test rake gems:install
  #
  # The following are just the gems needed when running cucumber
  #
  config.active_support.deprecation = :stderr
  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  # Turn this off if localizing
  config.i18n.default_locale = 'en'
  config.i18n.fallbacks = true

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

  LogConfig.configure(config, ENV['TEST_LOG_LEVEL'], 'WARN')
end
