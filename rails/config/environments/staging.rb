RailsPortal::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Enable threaded mode
  # config.threadsafe!

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Full error reports are disabled and caching is turned on
  config.action_controller.consider_all_requests_local = false
  config.action_controller.perform_caching             = true

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host                  = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false
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
