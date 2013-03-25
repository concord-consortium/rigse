RailsPortal::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

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
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  #### Asset Pipeline:  #####
  
  # Minify/uglify/compress assets from the pipeline
  config.assets.compress = true
  config.assets.js_compressor = :uglifier
  config.assets.css_compressor = :yui
  config.assets.precompile += %w(
    print.css
    otml.css
    project.css
    jquery/jquery.js
    pie/PIE.js
    calendar_date_select/calendar_date_select.js
    calendar_date_select/silver.css
    contentflow_configured.css
    contentflow_configured.js
    web/search_materials.css
    )

  # add in the current theme's application.css
  # a proc is used here so the APP_CONFIG is available
  config.assets.precompile << Proc.new do |path|
    path == "APP_CONFIG[:theme]/stylesheets/application.css"
  end

  # Production servers may compile missing assets. (missed by precompile)
  # Requires asset helper gems in production bundle
  config.assets.compile = true
  
  # Generate digests for assets' URLs.
  config.assets.digest = true
  config.action_mailer.default_url_options = { :host => APP_CONFIG[:host] }
end
