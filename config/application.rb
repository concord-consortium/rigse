require File.expand_path('../boot', __FILE__)

require 'rails/all'

require File.expand_path('../../lib/load_config', __FILE__)

module RailsPortal
  class Application < Rails::Application
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

    config.filter_parameters << :password << :password_confirmation

    # Subvert the cookies_only=true session policy for requests ending in ".config"
    config.middleware.insert_before("ActionDispatch::Cookies", "Rack::ConfigSessionCookies")

    # ExpandB64Gzip needs to be before ActionController::ParamsParser in the rack middleware stack:
    #   $ rake middleware
    #   (in /Users/stephen/dev/ruby/src/webapps/rigse2.git)
    #   use Rack::Lock
    #   use ActionController::Failsafe
    #   use ActionController::Reloader
    #   use ActiveRecord::ConnectionAdapters::ConnectionManagement
    #   use ActiveRecord::QueryCache
    #   use ActiveRecord::SessionStore, #<Proc:0x0192dfc8@(eval):8>
    #   use Rack::ExpandB64Gzip
    #   use ActionController::ParamsParser
    #   use Rack::MethodOverride
    #   use Rack::Head
    #   run ActionController::Dispatcher.new

    config.middleware.insert_before("ActionDispatch::ParamsParser", "Rack::ExpandB64Gzip")

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

    # Set the default location for page caching
    config.action_controller.page_cache_directory = ::Rails.root.to_s + '/public'

    config.react.variant = :development

    # Use SQL instead of Active Record's schema dumper when creating the test database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Activate observers that should always be running
    # Please note that observers generated using script/generate observer need to have an _observer suffix

    # ... observers are now started in config/initializers/observers.rb
    # Nov 10 NP: This technique wasn't working, so, I figued we would just surround w/ begin / rescue
    # if ActiveRecord::Base.connection_handler.connection_pools["ActiveRecord::Base"].connected?
    if $PROGRAM_NAME =~ /rake/ && ARGV.grep(/^db:migrate/).length > 0
      puts "Didn't start observers because you are running: rake db:migrate"
    else
        begin
          config.active_record.observers = :user_observer, :investigation_observer, :"dataservice/bundle_content_observer", :"admin/settings_observer", :"dataservice/periodic_bundle_content_observer"
        rescue
          # interestingly Rails::logger doesn't seem to be working here, so I am using ugly puts for now:
          puts "Couldn't start observers #{$!} ... but continuing process anyway"
          puts "This might be because you have not setup the appropriate database tables yet... "
          puts "see config/initializers/observers.rb for more information."
        end
    end

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

    config.assets.enabled = true
    config.assets.precompile += %w(
      print.css
      otml.css
      student_roster.js
      class_setup_info.js
      manage_classes.js
      full_status.js
      instructional_materials.js
      preview_home_page.js
      preview_help_page.js
      share_material.js
      settings_form.js
      jquery/jquery.js
      pie/PIE.js
      calpicker/calendar_date_select.js
      calpicker/silver.css
      web/search_materials.css
      readme.css
      print.css
      import_progress.js
      import_model_library.js
    )

    # pre-compile any fonts in the assets/ directory as well
    config.assets.precompile << /\.(?:svg|eot|woff|ttf)\z/

    # add in the current theme's application.css
    # a proc is used here so the APP_CONFIG is available
    config.assets.precompile << Proc.new do |path|
      path == "APP_CONFIG[:theme]/stylesheets/application.css"
    end

    # do not initialize on precompile so that the Dockerfile can run the precompile
    if ENV['DOCKER_NO_INIT_ON_PRECOMPILE']
      config.assets.initialize_on_precompile = false
    end

  end

  # ANONYMOUS_USER = User.find_by_login('anonymous')
end
