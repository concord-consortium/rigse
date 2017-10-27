RailsPortal::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

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

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  #### Asset Pipeline:  #####

  # Minify/uglify/compress assets from the pipeline
  config.assets.compress = false

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
    # Bullet.bullet_logger = true
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
end
