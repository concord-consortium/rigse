require File.expand_path('../boot', __FILE__)

require 'rails/all'

module RailsPortal
  class Application < Rails::Application
    config.assets.enabled = true
    # Bundler.require(:default, Rails.env) if defined?(Bundler)
    # Fixes a Compass bug, per http://stackoverflow.com/questions/6005361/sass-import-error-in-rails-3-app-file-to-import-not-found-or-unreadable-comp?rq=1
    Bundler.require(*Rails.groups(:assets => %w(development test))) if defined?(Bundler)
  
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
          config.active_record.observers = :user_observer, :investigation_observer, :"dataservice/bundle_content_observer", :"admin/project_observer", :"dataservice/periodic_bundle_content_observer"
          puts "Started observers"
        rescue
          # interestingly Rails::logger doesn't seem to be working here, so I am using ugly puts for now:
          puts "Couldn't start observers #{$!} ... but continuing process anyway"
          puts "This might be because you have not setup the appropriate database tables yet... "
          puts "see config/initializers/observers.rb for more information."
        end
    end

  end
  
  # ANONYMOUS_USER = User.find_by_login('anonymous')
end
