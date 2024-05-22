RailsPortal::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Eager loads all registered config.eager_load_namespaces. This includes your application, engines, Rails frameworks, and any other registered namespace.
  config.eager_load = true

  # this will fall back to autoloading to files outside the app folder
  config.enable_dependency_loading = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See info messages and above in the log (default is :debug in Rails 5)
  config.log_level = :info

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new
  if BoolENV['RAILS_STDOUT_LOGGING']
    config.logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
  end

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = true

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.default_locale = 'en'
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  #### Asset Pipeline:  #####
  # Production servers may not compile missing assets. (missed by precompile)
  # Requires asset helper gems in production bundle
  config.assets.compile = true

  # Minify/uglify/compress assets from the pipeline
  config.assets.js_compressor = :terser
  config.assets.css_compressor = :yui

  # Generate digests for assets' URLs.
  config.assets.digest = true
  config.action_mailer.default_url_options = {:protocol => APP_CONFIG[:protocol], :host => APP_CONFIG[:host] }
  config.action_mailer.asset_host = APP_CONFIG[:protocol] + '://' + APP_CONFIG[:host]

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

end
