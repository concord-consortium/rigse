namespace :rigse do
  
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
    
    require 'uuidtools'
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
    
    desc "erase and import ITSI activities"
    task :erase_and_import_itsi_activities => :environment do
      if ActiveRecord::Base.configurations['itsi']
        Activity.find(:all, :conditions => "name like 'ITSI%'").each {|i| print '.'; i.destroy }
        itsi_user = Itsi::User.find_by_login('itest')
        rites_user = User.find_by_email(APP_CONFIG[:admin_email])
        itsi_activities = Itsi::Activity.find_all_by_user_id_and_collectdata_model_active_and_public(itsi_user, false, true)
        itsi_activities.each {|a| print '.'; Activity.create_from_itsi(a, rites_user) }
      else
        puts "need an ITSI specification in database.yml to run this task"
      end
    end
    
    #######################################################################
    #
    # Raise an error unless the RAILS_ENV is development
    #
    #######################################################################
    desc "Raise an error unless the RAILS_ENV is development"
    task :development_environment_only do
      raise "Hey, development only you monkey!" unless RAILS_ENV == 'development'
    end
    
    
    #######################################################################
    #
    # Regenerate the REST_AUTH_SITE_KEY 
    #
    #######################################################################
    desc "regenerate the REST_AUTH_SITE_KEY -- all passwords will become invalid"
    task :regenerate_rest_auth_site_key => :environment do
      
      puts <<HEREDOC

This task will re-generate a REST_AUTH_SITE_KEY and update
the file config/initializers/site_keys.rb.

Completing this will invalidate existing passwords. Users will
need to complete the "forgot password" process to revalidate
their passwords even though their actual password hasn't changed.

If the application is running it will need to be restarted for
this change to take effect.

HEREDOC
      
      if agree("Do you want to do this?  (y/n)", true)
        site_keys_path = rails_file_path(%w{config initializers site_keys.rb})
        site_key = UUID.timestamp_create().to_s

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
    desc "setup a new rigse instance"
    task :new_rigse_from_scratch => :environment do
      
      puts <<HEREDOC

This task will drop your extsing rigse database, rebuild it from scratch, 
and install default users.
  
HEREDOC
      if agree("Do you want to do this?  (y/n)", true)
        begin
          Rake::Task['db:drop'].invoke
        rescue Exception
        end
        Rake::Task['rigse:setup:development_environment_only'].invoke
        Rake::Task['db:create'].invoke
        Rake::Task['db:migrate'].invoke
        Rake::Task['rigse:setup:default_users_roles'].invoke
        Rake::Task['rigse:setup:create_additional_users'].invoke
        Rake::Task['rigse:setup:import_gses_from_file'].invoke
        Rake::Task['rigse:setup:assign_vernier_golink_to_users'].invoke
        Rake::Task['db:backup:load_probe_configurations'].invoke
        Rake::Task['rigse:setup:assign_vernier_golink_to_users'].invoke
  
        puts <<HEREDOC

You can now start RI-GSE in develelopment mode by running this command:

  script/server

You can re-edit the initial configuration parameters by running the
setup script again:

  ruby config/setup.rb

You can re-create the database from scratch and setup default users 
again by running this rake task again:

  rake rigse:setup:new_rigse_from_scratch
  
HEREDOC
      end
    end
    
    def edit_user(user)
      require 'highline/import'
      
      puts <<HEREDOC

Editing user: #{user.login}

HEREDOC

      user.login =                 ask("            login: ") {|q| q.default = user.login}
      user.email =                 ask("            email: ") {|q| q.default = user.email}
      user.first_name =            ask("       first name: ") {|q| q.default = user.first_name}
      user.last_name =             ask("        last name: ") {|q| q.default = user.last_name}
      user.password =              ask("         password: ") {|q| q.default = user.password}
      user.password_confirmation = ask(" confirm password: ") {|q| q.default = user.password_confirmation}
      
      user
    end


    #######################################################################
    #
    # Create additional users
    #
    #######################################################################
    #
    # additional_users.yml is a YAML file that includes a list of users
    # to create when setting up a new instance. The salt and crypted_password
    # are specified for these users.
    #
    # A role specification is optional.
    #
    # Here's an example of how to create and additional_users.yml file:
    #
    # additional_users = { "stephen" =>
    #   { "role"=>"admin", 
    #     "first_name"=>"Stephen", 
    #     "last_name"=>"Bannasch", 
    #     "email"=>"stephen.bannasch@gmail.com"}
    #   }
    # File.open(File.join(RAILS_ROOT, %w{config additional_users.yml}), 'w') {|f| YAML.dump(additional_users, f)}
    # 
    # The additional users will be created but each one will need to go to the
    # forgot password link to actually get a working password:
    #
    #   http://rigse-dev.concord.org/rigse/forgot_password
    #
    desc "Create additional users from additional_users.yml file."
    task :create_additional_users => :environment do
      begin
        path = File.join(RAILS_ROOT, %w{config additional_users.yml})
        additional_users = YAML::load(IO.read(path))
        puts "\nCreating additional users ...\n\n"
        pw = User.make_token
        additional_users.each do |user_config|
          puts "  #{user_config[1]['role']} #{user_config[0]}: #{user_config[1]['first_name']} #{user_config[1]['last_name']}, #{user_config[1]['email']}"
          u = User.create(:login => user_config[0], 
            :first_name => user_config[1]['first_name'], 
            :last_name => user_config[1]['last_name'], 
            :email => user_config[1]['email'], 
            :password => pw, 
            :password_confirmation => pw)
          u = User.find_by_login(user_config[0])
          u.register!
          u.activate!
          role_title = user_config[1]['role']
          if role_title
            role = Role.find_by_title(role_title)
            u.roles << role
          end
        end
        puts "\n"
      rescue SystemCallError => e
        # puts e.class
        # puts "#{path} not found"
      end
    end


    #######################################################################
    #
    # Assign Vernier go!Link as default vendor_interface for users
    # without a vendor_interface.
    #
    #######################################################################
    desc "Assign Vernier go!Link as default vendor_interface for users without a vendor_interface."
    task :assign_vernier_golink_to_users => :environment do
      interface = VendorInterface.find_by_short_name('vernier_goio')
      User.find(:all).each do |u|
        unless u.vendor_interface
          u.vendor_interface = interface
          u.save
        end
      end
    end
   
   
    #######################################################################
    #
    # Create default users and roles
    #
    #######################################################################   
    desc "Create default users and roles"
    task :default_users_roles => :environment do

      puts <<HEREDOC

This task creates seven roles (if they dont already exist):

  admin
  manager
  researcher
  teacher
  member
  student
  guest

In addition it create four new default users with these login names:

  anonymous
  admin
  researcher
  member

You can edit the default settings for these users.

HEREDOC

      admin_role = Role.find_or_create_by_title('admin')
      manager_role = Role.find_or_create_by_title('manager')
      researcher_role = Role.find_or_create_by_title('researcher')
      teacher_role = Role.find_or_create_by_title('teacher')
      member_role = Role.find_or_create_by_title('member')
      student_role = Role.find_or_create_by_title('student')
      guest_role = Role.find_or_create_by_title('guest')

      anonymous_user = User.create(:login => "anonymous", :email => "anonymous@concord.org", :password => "password", :password_confirmation => "password", :first_name => "Anonymous", :last_name => "User")
      admin_user = User.create(:login => "admin", :email => "admin@concord.org", :password => "password", :password_confirmation => "password", :first_name => "Admin", :last_name => "User")
      researcher_user = User.create(:login => 'researcher', :first_name => 'Researcher', :last_name => 'User', :email => 'researcher@concord.org', :password => "password", :password_confirmation => "password")
      member_user = User.create(:login => 'member', :first_name => 'Member', :last_name => 'User', :email => 'member@concord.org', :password => "password", :password_confirmation => "password")

      [admin_user, researcher_user, member_user, anonymous_user].each do |user|
        user = edit_user(user)
        user.save
        user.register!
        user.activate!
      end

      admin_user.roles << admin_role 
      researcher_user.roles << researcher_role
      member_user.roles << member_role
      
    end


    #######################################################################
    #
    # Force Create default users and roles
    # (similar to Create Default users, but without prompting)
    #######################################################################   
    desc "Force Create default users and roles"
    task :force_default_users_roles => :environment do
      admin_role = Role.find_or_create_by_title('admin')
      manager_role = Role.find_or_create_by_title('manager')
      researcher_role = Role.find_or_create_by_title('researcher')
      teacher_role = Role.find_or_create_by_title('teacher')
      member_role = Role.find_or_create_by_title('member')
      student_role = Role.find_or_create_by_title('student')
      guest_role = Role.find_or_create_by_title('guest')

      anonymous_user = User.create(:login => "anonymous", :email => "anonymous@concord.org", :password => "password", :password_confirmation => "password", :first_name => "Anonymous", :last_name => "User")
      admin_user = User.create(:login => "admin", :email => "admin@concord.org", :password => "password", :password_confirmation => "password", :first_name => "Admin", :last_name => "User")
      researcher_user = User.create(:login => 'researcher', :first_name => 'Researcher', :last_name => 'User', :email => 'researcher@concord.org', :password => "password", :password_confirmation => "password")
      member_user = User.create(:login => 'member', :first_name => 'Member', :last_name => 'User', :email => 'member@concord.org', :password => "password", :password_confirmation => "password")

      [admin_user, researcher_user, member_user].each do |user|
        user.save
        user.register!
        user.activate!
      end
      admin_user.roles << admin_role 
      researcher_user.roles << researcher_role
    end
    
    #######################################################################
    #
    # Force New from scratch
    #
    #######################################################################
    desc "force setup a new rigse instance, with no prompting! Danger!"
    task :force_new_rigse_from_scratch => :environment do

      puts <<-HEREDOC
      This task will drop your extsing rigse database, rebuild it from scratch, 
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