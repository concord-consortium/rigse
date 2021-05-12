RailsPortal::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Eager loads all registered config.eager_load_namespaces. This includes your application, engines, Rails frameworks, and any other registered namespace.
  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  # config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.default_url_options = {:protocol => APP_CONFIG[:protocol], :host => APP_CONFIG[:host] }
  config.action_mailer.delivery_method = :test
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.asset_host = APP_CONFIG[:protocol] + '://' + APP_CONFIG[:host]


  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

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

  #### Asset Pipeline:  #####


  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  # Turn this off if localizing
  #
  # Example testing other locales set:
  # config.i18n.default_locale = 'en-ITSI-LEARN'
  #
  config.i18n.default_locale = 'en'
  config.i18n.fallbacks = true

  # split apart assets to make debugging easier
  # This slows things down, but its also handy for x-ray
  # https://github.com/brentd/xray-rails
  # Comment out locally if you need speed.
  config.assets.debug = true

  config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = !BoolENV["RAILS_STDOUT_LOGGING"]
    Bullet.rails_logger = true
    Bullet.add_footer = true
  end

  # include per developer environment files if found (the default is excluded by .gitignore)
  #
  # Here is a sample local-development.rb file to speed up requests
  #
  # RailsPortal::Application.configure do
  #   config.assets.debug = false
  #   config.after_initialize do
  #     Bullet.enable = false
  #     Bullet.bullet_logger = false
  #     Bullet.rails_logger = false
  #     Bullet.add_footer = false
  #   end
  # end
  localDevPath = File.expand_path((ENV['LOCAL_DEV_ENVIRONMENT_FILE'] || 'local-development.rb'), File.dirname(__FILE__))
  require(localDevPath) if File.file?(localDevPath)


  # Rails 5 defaults to disable submit
  config.action_view.automatically_disable_submit_tag = false

  LogConfig.configure(config, ENV['DEV_LOG_LEVEL'], 'DEBUG')
end
