namespace :app do
  
  JRUBY = defined? RUBY_ENGINE && RUBY_ENGINE == 'jruby'

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
      File.join([RAILS_ROOT] + args)
    end


    desc "setup initial probe_type for data_collectors that don't have one"
    task :set_probe_type_for_data_collectors => :environment do
      Embeddable::DataCollector.find(:all).each do |dc| 
        if pt = Probe::ProbeType.find_by_name(dc.y_axis_label)
          dc.probe_type = pt
          dc.save
        end
      end
    end
    
    #######################################################################
    #
    # Raise an error unless the RAILS_ENV is development,
    # unless the user REALLY wants to run in another mode.
    #
    #######################################################################
    desc "Raise an error unless the RAILS_ENV is development"
    task :development_environment_only => :environment  do
      unless RAILS_ENV == 'development'
        puts "\nNormally you will only be running this task in development mode.\n"
        puts "You are running in #{RAILS_ENV} mode.\n"
        unless HighLine.new.agree("Are you sure you want to do this?  (y/n) ")
          raise "task stopped by user"
        end
      end
    end
    
    #######################################################################
    #
    # Regenerate the REST_AUTH_SITE_KEY 
    #
    #######################################################################
    desc "regenerate the REST_AUTH_SITE_KEY -- all passwords will become invalid"
    task :regenerate_rest_auth_site_key => :environment do
      
      gem "uuidtools", '>= 2.0.0'
      require 'uuidtools'
      
      puts <<-HEREDOC

This task will re-generate a REST_AUTH_SITE_KEY and update
the file config/initializers/site_keys.rb.

Completing this will invalidate existing passwords. Users will
need to complete the "forgot password" process to revalidate
their passwords even though their actual password hasn't changed.

If the application is running it will need to be restarted for
this change to take effect.

      HEREDOC
      
      if HighLine.new.agree("Do you want to do this?  (y/n) ")
        site_keys_path = rails_file_path(%w{config initializers site_keys.rb})
        site_key = UUIDTools::UUID.timestamp_create.to_s

        site_keys_rb = <<-HEREDOC
REST_AUTH_SITE_KEY = '#{site_key}'
REST_AUTH_DIGEST_STRETCHES = 10
        HEREDOC

        File.open(site_keys_path, 'w') {|f| f.write site_keys_rb }
        FileUtils.chmod 0660, site_keys_path
      end
    end
    
    
    #######################################################################
    #
    # Setup a new instance
    #
    #######################################################################
    desc "setup a new app instance, run: ruby config/setup.rb first"
    task :new_app => :environment do

      db_config = ActiveRecord::Base.configurations[RAILS_ENV]

      # Rake::Task['app:setup:development_environment_only'].invoke
      
      puts <<-HEREDOC

This task will:

 1. create default users and roles
 2. optionally create additional users
 3. load default probe, interface, and calibration reesources
 4. generate a set of the RI Grade Span Expectation models (if using the 'rites' theme)
 5. assign the Vernier Go!Link interface as a default to the existing users
 6. generate the maven_jnlp resources (if :runnables_use: otrunk_jnlp in app settings)
 7. optionally download, introspect, and create models representing otrunk-examples 
 8. create a default project and associate it with the maven_jnlp resources
 9. download and generate nces district and school resources
10. Generate District and School model instances from the NCES data for selected States and Active School Levels.
11. create default portal resources: district, school, class, investigation and offering
  
      HEREDOC
      if RAILS_ENV != 'development' || HighLine.new.agree("Do you want to do this?  (y/n) ")
        # Rake::Task['gems:install'].invoke
        Rake::Task['app:setup:default_users_roles'].invoke
        Rake::Task['app:setup:create_additional_users'].invoke
        Rake::Task['db:backup:load_probe_configurations'].invoke
        # FIXME: when and if any other projects/themes need RI GSE models
        if USING_RITES
          Rake::Task['db:backup:load_ri_grade_span_expectations'].invoke
        end
        Rake::Task['app:convert:assign_vernier_golink_to_users'].invoke
        if USING_JNLPS
          Rake::Task['app:jnlp:generate_maven_jnlp_resources'].invoke
        end
        if APP_CONFIG[:include_otrunk_examples]
          Rake::Task['app:import:generate_otrunk_examples_rails_models'].invoke
        else
          puts "\n\nskipping task: rake rigse:import:generate_otrunk_examples_rails_models\n\n"
        end
        Rake::Task['app:convert:create_default_project_from_config_settings_yml'].invoke
        Rake::Task['portal:setup:download_nces_data'].invoke
        Rake::Task['portal:setup:import_nces_from_files'].invoke
        Rake::Task['portal:setup:create_districts_and_schools_from_nces_data'].invoke
        Rake::Task['app:setup:default_portal_resources'].invoke

  
        puts <<-HEREDOC

Start the application in development mode by running this command:

  #{jruby_run_server_command}script/server

Start the application in production mode by running this command:

  #{jruby_run_server_command}script/server -e production

Re-edit the initial configuration parameters by running the
setup script again:

  #{jruby_run_command}config/setup.rb

Re-create the database from scratch and setup default users 
again by running these rake tasks in sequence again:

  RAILS_ENV=production #{jruby_system_command} rake db:migrate:reset
  RAILS_ENV=production #{jruby_system_command} rake rigse:setup:new_app


If you have access to an ITSI database you can also import ITSI activities 
into #{APP_CONFIG[:theme].upcase} by running this rake task:

  #{jruby_system_command} rake rigse:import:erase_and_import_itsi_activities

* if you are developing locally and are using the same database for both development and production
  environments the ITSI import will run much faster in production mode:

  RAILS_ENV=production #{jruby_system_command} rake rigse:import:erase_and_import_itsi_activities

If you have access to a CCPortal database that indexes ITSI Activities into sequenced Units 
you can also import these ITSI activities into #{APP_CONFIG[:theme].upcase} Investigations by running this rake task:

  #{jruby_system_command} rake rigse:import:erase_and_import_ccp_itsi_units

If you have ssh access to the #{APP_CONFIG[:theme].upcase} production server you can get a copy of the production database on
your local development instance with the following steps:

  cap production db:fetch_remote_db
  RAILS_ENV=production #{jruby_system_command}  rake db:load

If the codebase on your development system has moved ahead of production you may need to run additional tasks such as:

  RAILS_ENV=production #{jruby_system_command}  rake db:migrate
  RAILS_ENV=production #{jruby_system_command}  rake rigse:setup:default_portal_resources
  RAILS_ENV=production #{jruby_system_command}  rake portal:setup:create_districts_and_schools_from_nces_data

The task: default_users_roles_and_portal_resources is last on that list because code changes may have added additional 
and necessary default model initialization.

In order for the same passwords to work you will also need to have the same keys in your local 
config/initializers/site_keys.rb as on the server you copied the production data from.

  cap production db:copy_remote_site_keys</code></pre>


        HEREDOC
      end
    end

    #######################################################################
    #
    # Force New from scratch
    #
    #######################################################################
    #
    # seb 20100719: I've commented this task out -- I don't think it works anymore.
    #
    # desc "force setup a new rigse instance, with no prompting! Danger!"
    # task :force_new_rigse_from_scratch => :environment do
    #   
    #   db_config = ActiveRecord::Base.configurations[RAILS_ENV]
    # 
    #   puts <<-HEREDOC
    #   This task will drop your existing rigse database: #{db_config['database']}, rebuild it from scratch, 
    #   and install default users.
    #   HEREDOC
    #     # save the old data?
    #     # Rake::Task['app:setup:development_environment_only'].invoke
    #     Rake::Task['db:reset'].invoke
    #     Rake::Task['app:setup:force_default_users_roles'].invoke
    #     Rake::Task['app:setup:create_additional_users'].invoke
    #     Rake::Task['app:setup:import_gses_from_file'].invoke
    #     Rake::Task['db:backup:load_probe_configurations'].invoke
    #     Rake::Task['app:setup:assign_vernier_golink_to_users'].invoke
    # end
  end
end