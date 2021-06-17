require File.expand_path('../boot', __FILE__)

require 'rails/all'

require File.expand_path('../../lib/load_config', __FILE__)
require File.expand_path('../../lib/bool_env', __FILE__)

# loads Rack::ConfigSessionCookies for middleware configuration
require File.expand_path("../../lib/rack/config_session_cookies", __FILE__)

# load Rack::ResponseLogger for middleware configuration
require File.expand_path("../../lib/rack/response_logger", __FILE__)

# load Rack::ExpandB64Gzip for middleware configuration
require File.expand_path("../../lib/rack/expand_b64_gzip", __FILE__)

module RailsPortal
  class Application < Rails::Application
    config.load_defaults 6.0
    config.autoloader = :classic

    config.assets.precompile << 'delayed/web/application.css'
    config.rails_lts_options = { default: :compatible }
    # Use RSpec when generating tests, not test_unit
    config.generators do |g|
      g.test_framework :rspec
    end

    # Bundler.require(:default, Rails.env) if defined?(Bundler)
    # Fixes a Compass bug, per http://stackoverflow.com/questions/6005361/sass-import-error-in-rails-3-app-file-to-import-not-found-or-unreadable-comp?rq=1
    app_environment_variables = File.join(Rails.root, 'config', 'app_environment_variables.rb')
    if File.exists?(app_environment_variables)
      load(app_environment_variables)
    else
      # TODO: Should we just die here otherwise?
      puts "please create the file #{app_environment_variables}, or set ENV"
    end
    extra_groups = {:assets => %w(development test cucumber)}
    if ENV['PORTAL_FEATURES'] && !ENV['PORTAL_FEATURES'].empty?
      ENV['PORTAL_FEATURES'].split(/\s+/).each do |feature|
        extra_groups[feature.to_sym] = %w(development test cucumber production)
        puts "enabling portal feature: #{feature}"
      end
    end
    Bundler.require(*Rails.groups(extra_groups)) if defined?(Bundler)

    config.autoload_paths += Dir["#{config.root}/lib/**/"] # include lib and all subdirectories
    config.autoload_paths += Dir["#{config.root}/app/pdfs/**/"] # include app/reports and all subdirectories
    config.autoload_paths += Dir["#{config.root}/app/helpers/"] # include app/helpers and all subdirectories

    config.filter_parameters << :password << :password_confirmation

    # Subvert the cookies_only=true session policy for requests ending in ".config"
    config.middleware.insert_before(ActionDispatch::Cookies, Rack::ConfigSessionCookies)

    # Expands posted content with a content-encoding of: 'b64gzip'
    # NOTE: pre-Rails 5 this was inserted before ActionController::ParamsParser but that middleware
    # was deprecated in Rails 5 so Rack::Head was chosen based on posts found online about compression middlewares
    config.middleware.insert_before(Rack::Head, Rack::ExpandB64Gzip)

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    # See Rails::Configuration for more options.

    # Skip frameworks you're not going to use. To use Rails without a database
    # you must remove the Active Record framework.
    # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

    # FIXME: see comment about this hack in config/environments/development.rb
    $: << 'vendor/gems/ffi-ncurses-0.3.2.1/lib/'
    # config.gem "ffi-ncurses ", :version => "= 0.3.3"
    # These cause problems with irb. Left in for reference
    # config.gem 'rspec-rails', :lib => 'spec/rails', :version => '1.1.11'
    # config.gem 'rspec', :lib => 'spec', :version => '1.1.11'
    # Only load the plugins named here, in the order given. By default, all plugins
    # in vendor/plugins are loaded in alphabetical order.
    # :all can be used as a placeholder for all plugins not explicitly named
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Add additional load paths for your own custom dirs
    # config.load_paths += %W( #{::Rails.root.to_s}/extras )
    # Force all environments to use the same logger level
    # (by default production uses :info, the others :debug)
    # config.log_level = :debug

    # Make Time.zone default to the specified zone, and make Active Record store time values
    # in the database in UTC, and return them converted to the specified local zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Comment line to use default local time.
    config.time_zone = 'UTC'

    # Use SQL instead of Active Record's schema dumper when creating the test database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Activate observers that should always be running
    # Please note that observers generated using script/generate observer need to have an _observer suffix

    config.middleware.insert_before 0, Rack::Cors do

      allow do
        origins '*'
        # always allow export access to the model library
        resource '/interactives/export_model_library', :headers => :any, :methods => :get
        # always allow access to the class#info
        resource '/portal/classes/info', :headers => :any, :methods => :get
        resource '/api/v1/reports/*', :headers => :any, :methods => [:get, :put]
        resource '/api/v1/offerings/*', :headers => :any, :methods => [:get, :put]
        resource '/api/v1/offering/*', :headers => :any, :methods => [:get, :put]
        resource '/api/v1/classes/*', :headers => :any, :methods => [:get]
        resource '/api/v1/jwt/*', :headers => :any, :methods => [:get]
        resource '/api/v1/bookmarks', :headers => :any, :methods => [:post]
        resource '/api/v1/bookmarks/*', :headers => :any, :methods => [:put, :delete]
      end

      # Set up custom CORS, if the environment variable PORTAL_FEATURES includes "allow_cors".

      # If CORS is allowed, then by default, we will allow CORS requests only from the origin
      # `*.concord.org`. If we want to specify something else, use the environment variable
      # CORS_ORIGINS, specifying multiple origins: CORS_ORIGINS="x.concord.org y.z.example.com".

      # We can also set which resources we allow with the CORS_RESOURCES environment variable.
      # By default, this is '*'
      if ENV['PORTAL_FEATURES'] && ENV['PORTAL_FEATURES'].include?("allow_cors")
        allow do
          origins ENV['CORS_ORIGINS'] ? ENV['CORS_ORIGINS'].split(" ") : /^https?:\/\/.*\.concord.org/
          resource ENV['CORS_RESOURCES'] || '*', headers: :any, expose: ['Location'], methods: [:get, :post, :put, :options], credentials: true
        end
      end
    end

    # Add a middlewere to log more info about the response
    config.middleware.insert_before 0, Rack::ResponseLogger

    config.assets.enabled = true
    config.assets.precompile += %w(
      print.css
      full_status.js
      preview_home_page.js
      preview_about_page.js
      preview_help_page.js
      share_material.js
      settings_form.js
      jquery/jquery.js
      pie/PIE.js
      web/search_materials.css
      readme.css
      print.css
      import_progress.js
      import_model_library.js
      jquery.placeholder.js
      themes/all.scss
    )

    # pre-compile any fonts in the assets/ directory as well
    config.assets.precompile << /\.(?:svg|eot|woff|ttf)\z/

    # do not initialize on precompile so that the Dockerfile can run the precompile
    if BoolENV['DOCKER_NO_INIT_ON_PRECOMPILE']
      config.assets.initialize_on_precompile = false
    end

    # use json format for serilized cookies
    config.action_dispatch.cookies_serializer = :hybrid



    # To improve security, Rails now embeds the expiry information also in encrypted or signed cookies value.
    # This new embed information make those cookies incompatible with versions of Rails older than 5.2.
    # If you require your cookies to be read by 5.1 and older, or you are still validating your 5.2 deploy
    # and want to allow you to rollback set Rails.application.config.action_dispatch.use_authenticated_cookie_encryption to false.
    config.action_dispatch.use_authenticated_cookie_encryption = true


    # To improve security, Rails embeds the purpose and expiry metadata inside encrypted or signed cookies value.
    # This new embed metadata make those cookies incompatible with versions of Rails older than 6.0.
    # If you require your cookies to be read by Rails 5.2 and older, or you are still validating your 6.0 deploy and want to be able
    # to rollback set Rails.application.config.action_dispatch.use_cookies_with_metadata to false.
    # Rails can then thwart attacks that attempt to copy the signed/encrypted value of a cookie and use it as the value of another cookie.
    config.action_dispatch.use_cookies_with_metadata = true


    # Specify cookies SameSite protection level: either :none, :lax, or :strict.
    # When running tests, we want to use lax protection (breaks cucumber tests otherwise)
    same_site_protection = (Rails.env.cucumber? || Rails.env.test? || Rails.env.feature_test?) ? :lax : :none
    config.action_dispatch.cookies_same_site_protection = same_site_protection

    # Allow requests from any domain (skips DNS rebinding attack guards)
    config.hosts = nil
  end

  # ANONYMOUS_USER = User.find_by_login('anonymous')
end
