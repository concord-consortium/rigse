namespace :rigse do
  
  JRUBY = defined? RUBY_ENGINE && RUBY_ENGINE == 'jruby'

  def jruby_system_command
    JRUBY ? "jruby -S" : ""
  end

  def jruby_run_command
    JRUBY ? "jruby " : "ruby "
  end
  
  def agree_check_in_development_mode
    if RAILS_ENV == 'development'
      agree("Accept defaults? (y/n) ", true)
    else
      true
    end
  end
  
  PLUGIN_LIST = {
    :acts_as_taggable_on_steroids => 'http://svn.viney.net.nz/things/rails/plugins/acts_as_taggable_on_steroids',
    :attachment_fu => 'git://github.com/technoweenie/attachment_fu.git',
    :bundle_fu => 'git://github.com/timcharper/bundle-fu.git',
    :fudge_form => 'git://github.com/JimNeath/fudge_form.git',
    :haml => 'git://github.com/nex3/haml.git',
    :jrails => 'git://github.com/aaronchi/jrails.git',
    :paperclip => 'git://github.com/thoughtbot/paperclip.git',
    :salty_slugs => 'git://github.com/norbauer/salty_slugs.git',
    :shoulda => 'git://github.com/thoughtbot/shoulda.git',
    :spawn => 'git://github.com/tra/spawn.git',
    :workling => 'git://github.com/purzelrakete/workling.git'
  }
  
  
  desc "display info about the site admin user"
  task :display_site_admin => :environment do
    puts User.site_admin.to_yaml
  end
  
  
  #######################################################################
  #
  # List all plugins available to quick install
  #
  #######################################################################  
  desc 'List all plugins available to quick install'
  task :install do
    puts "\nAvailable Plugins\n=================\n\n"
    plugins = PLUGIN_LIST.keys.sort_by { |k| k.to_s }.map { |key| [key, PLUGIN_LIST[key]] }
    
    plugins.each do |plugin|
      puts "#{plugin.first.to_s.gsub('_', ' ').capitalize.ljust(30)} rake rigse:install:#{plugin.first.to_s}\n"
    end
    puts "\n"
  end
  
  namespace :install do
    PLUGIN_LIST.each_pair do |key, value|
      task key do
        system('script/plugin', 'install', value, '--force')
      end
    end
  end

  namespace :setup do
    
    require 'highline/import'
    require 'fileutils'
    
    def rails_file_path(*args)
      File.join([RAILS_ROOT] + args)
    end


    desc "setup initial probe_type for data_collectors that don't have one"
    task :set_probe_type_for_data_collectors => :environment do
      DataCollector.find(:all).each do |dc| 
        if pt = ProbeType.find_by_name(dc.y_axis_label)
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
        unless agree("Are you sure you want to do this?  (y/n) ", true)
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
      
      puts <<HEREDOC

This task will re-generate a REST_AUTH_SITE_KEY and update
the file config/initializers/site_keys.rb.

Completing this will invalidate existing passwords. Users will
need to complete the "forgot password" process to revalidate
their passwords even though their actual password hasn't changed.

If the application is running it will need to be restarted for
this change to take effect.

HEREDOC
      
      if agree("Do you want to do this?  (y/n) ", true)
        site_keys_path = rails_file_path(%w{config initializers site_keys.rb})
        site_key = UUIDTools::UUID.timestamp_create.to_s

        site_keys_rb = <<HEREDOC
REST_AUTH_SITE_KEY = '#{site_key}'
REST_AUTH_DIGEST_STRETCHES = 10
HEREDOC

        File.open(site_keys_path, 'w') {|f| f.write site_keys_rb }
        FileUtils.chmod 0660, site_keys_path
      end
    end
    
    
    #######################################################################
    #
    # New from scratch
    #
    #######################################################################
    desc "setup a new rites instance, run: ruby config/setup.rb first"
    task :new_rites_app => :environment do
      db_config = ActiveRecord::Base.configurations[RAILS_ENV]

      # Rake::Task['rigse:setup:development_environment_only'].invoke
      
      puts <<HEREDOC

This task will:

1. drop the existing database: #{db_config['database']} and rebuild it from scratch
2. install any addition gems that are needed
3. generate a set of the RI Grade Span Expectation
4. generate the maven_jnlp resources
5. download and generate nces district and school resource
6. create default roles, users, district, school, teacher, student, class, and offering
7. create a default project and associate it with the maven_jnlp resources
  
HEREDOC
      if agree("Do you want to do this?  (y/n) ", true)
        begin
          Rake::Task['db:drop'].invoke
        rescue StandardException
        end
        Rake::Task['db:create'].invoke
        Rake::Task['db:migrate'].invoke
        Rake::Task['gems:install'].invoke
        Rake::Task['db:backup:load_probe_configurations'].invoke
        Rake::Task['rigse:setup:import_gses_from_file'].invoke
        Rake::Task['rigse:setup:create_additional_users'].invoke
        Rake::Task['rigse:setup:assign_vernier_golink_to_users'].invoke
        Rake::Task['rigse:jnlp:generate_maven_jnlp_family_of_resources'].invoke
        Rake::Task['rigse:import:generate_otrunk_examples_rails_models'].invoke
        Rake::Task['portal:setup:download_nces_data'].invoke
        Rake::Task['portal:setup:import_nces_from_file'].invoke
        Rake::Task['rigse:setup:default_users_roles_and_portal_resources'].invoke
        Rake::Task['rigse:convert:create_default_project_from_config_settings_yml'].invoke
  
        puts <<HEREDOC

You can now start the application in develelopment mode by running this command:

  #{jruby_run_command}script/server

You can re-edit the initial configuration parameters by running the
setup script again:

  #{jruby_run_command}config/setup.rb

You can re-create the database from scratch and setup default users 
again by running this rake task again:

  #{jruby_system_command} rake rigse:setup:new_rigse_from_scratch

If you have access to an ITSI database you can also import ITSI activities 
into RITES by running this rake task:

  #{jruby_system_command} rake rigse:import:erase_and_import_itsi_activities

* if you are developing locally and are using the same database for both development and production
  environments the ITSI import will run much faster in production mode:

  RAILS_ENV=production #{jruby_system_command} rake rigse:import:erase_and_import_itsi_activities

If you have access to a CCPortal database that indexes ITSI Activities into sequenced Units 
you can also import these ITSI activities into RITES Investigations by running this rake task:

  #{jruby_system_command} rake rigse:import:erase_and_import_ccp_itsi_units

* if you are developing locally and are using the same database for both development and production
  environments the ITSI import will run much faster in production mode:

  RAILS_ENV=production #{jruby_system_command} rake rigse:import:erase_and_import_ccp_itsi_units


HEREDOC
      end
    end

    #######################################################################
    #
    # Force New from scratch
    #
    #######################################################################
    desc "force setup a new rigse instance, with no prompting! Danger!"
    task :force_new_rigse_from_scratch => :environment do
      
      db_config = ActiveRecord::Base.configurations[RAILS_ENV]

      puts <<-HEREDOC
      This task will drop your existing rigse database: #{db_config['database']}, rebuild it from scratch, 
      and install default users.
      HEREDOC
        # save the old data?
        Rake::Task['rigse:setup:development_environment_only'].invoke
        Rake::Task['db:reset'].invoke
        Rake::Task['rigse:setup:force_default_users_roles'].invoke
        Rake::Task['rigse:setup:create_additional_users'].invoke
        Rake::Task['rigse:setup:import_gses_from_file'].invoke
        Rake::Task['db:backup:load_probe_configurations'].invoke
        Rake::Task['rigse:setup:assign_vernier_golink_to_users'].invoke
    end
  end
end