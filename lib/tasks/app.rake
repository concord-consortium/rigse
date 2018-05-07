namespace :app do
  
  JRUBY = defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'

  def jruby_system_command
    JRUBY ? "jruby -S" : ""
  end

  def jruby_run_command
    JRUBY ? "jruby " : "ruby "
  end

  def jruby_run_server_command
    jruby_run_command + (JRUBY ? "-J-server " : "")
  end

  desc "display info about the site admin user"
  task :display_site_admin => :environment do
    puts User.site_admin.to_yaml
  end

  namespace :setup do
    
    # require 'highline/import'
    autoload :Highline, 'highline'

    require 'fileutils'

    def rails_file_path(*args)
      File.join([::Rails.root.to_s] + args)
    end


    #######################################################################
    #
    # Raise an error unless the Rails.env is development,
    # unless the user REALLY wants to run in another mode.
    #
    #######################################################################
    desc "Raise an error unless the Rails.env is development"
    task :development_environment_only => :environment  do
      unless ::Rails.env == 'development'
        puts "\nNormally you will only be running this task in development mode.\n"
        puts "You are running in #{::Rails.env} mode.\n"
        unless HighLine.new.agree("Are you sure you want to do this?  (y/n) ")
          raise "task stopped by user"
        end
      end
    end
  end
end
