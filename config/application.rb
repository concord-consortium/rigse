require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)
module RailsPortal
  class Application < Rails::Application
    
    Bundler.require(:default, Rails.env) if defined?(Bundler)
  
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
    config.autoload_paths += %W(#{config.root}/lib) # include lib directory
    config.autoload_paths += %W(#{config.root}/lib/**/") # include all subdirectories
    
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
      config.after_initialize do
        begin
          ActiveRecord::Base.observers = :user_observer, :investigation_observer, :"dataservice/bundle_content_observer", :"admin/project_observer"
          ActiveRecord::Base.instantiate_observers
          puts "Started observers"
        rescue
          # interestingly Rails::logger doesn't seem to be working here, so I am using ugly puts for now:
          puts "Couldn't start observers #{$!} ... but continuing process anyway"
          puts "This might be because you have not setup the appropriate database tables yet... "
          puts "see config/initializers/observers.rb for more information."
        end
      end
    end
  
  
    # config.after_initialize do
    #   opts = config.has_many_polymorphs_options
    #   opts[:file_pattern] = Array(opts[:file_pattern])
    #   opts[:file_pattern] << "#{::Rails.root.to_s}/app/models/**/*.rb"
    #   config.has_many_polymorphs_options = opts
    # end
  
  end
  
  # ANONYMOUS_USER = User.find_by_login('anonymous')
  
  require 'prawn'
  require 'prawn/format'
  
  # Special-case for when the migration that adds the default_user
  # attribute hasn't been run yet.
  # TODO: This causes troubles when the user table is not present.
  # Like on a fresh install, or in various migration situations
  # begin
  #   site_admin = User.site_admin
  #   if site_admin.respond_to? :default_user
  #     if APP_CONFIG[:enable_default_users]
  #       User.unsuspend_default_users
  #     else
  #       User.suspend_default_users
  #     end
  #   end
  # rescue StandardError => e
  # # rescue Mysql::Error => e
  #   puts "e"
  # end
  
  module Enumerable
    # An extended group_by which will group at multiple depths
    # Ex:
    # >> ["aab","abc","aba","abd","aac","ada"].extended_group_by([lambda {|e| e.first}, lambda {|e| e.first(2)}])
    # => {"a"=>{"aa"=>["aab", "aac"], "ab"=>["abc", "aba", "abd"], "ad"=>["ada"]}}
  
    def extended_group_by(lambdas)
      lamb = lambdas.shift
      result = lamb ? self.group_by{|e| lamb.call(e)} : self
      if lambdas.size > 0
        final = {}
        temp = result.map{|k,v| {k => v.extended_group_by(lambdas.clone)}}
        temp.each {|r| final.merge!(r) }
        result = final
      end
      return result
    end
  end
end
