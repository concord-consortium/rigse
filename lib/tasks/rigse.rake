namespace :rigse do
  
  PLUGIN_LIST = {
    :acts_as_taggable_on_steroids => 'http://svn.viney.net.nz/things/rails/plugins/acts_as_taggable_on_steroids',
    :attachment_fu => 'git://github.com/technoweenie/attachment_fu.git',
    :bundle_fu => 'git://github.com/timcharper/bundle-fu.git',
    :fudge_form => 'git://github.com/JimNeath/fudge_form.git',
    :haml => 'git://github.com/nex3/haml.git',
    :jrails => 'git://github.com/aaronchi/jrails.git',
    :open_id_authentication => 'git://github.com/rails/open_id_authentication.git',
    :paperclip => 'git://github.com/thoughtbot/paperclip.git',
    :salty_slugs => 'git://github.com/norbauer/salty_slugs.git',
    :shoulda => 'git://github.com/thoughtbot/shoulda.git',
    :spawn => 'git://github.com/tra/spawn.git',
    :workling => 'git://github.com/purzelrakete/workling.git'
  }
  
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
    
    desc "Raise an error unless the RAILS_ENV is development"
    task :development_environment_only do
      raise "Hey, development only you monkey!" unless RAILS_ENV == 'development'
    end

    desc "setup a new rigse instance"
    task :new_rigse_from_scratch => :environment do
      begin
        Rake::Task['db:drop'].invoke
      rescue Exception
      end
      Rake::Task['rigse:setup:development_environment_only'].invoke
      Rake::Task['db:create'].invoke
      Rake::Task['db:migrate'].invoke
      Rake::Task['rigse:setup:default_users_roles'].invoke
      
      puts <<HEREDOC

You can now start the RI-GSE by running this command:

  script/server

You can re-edit the configuration parameters by running:

  ruby config/setup.rb
  
HEREDOC

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

    desc "Create default users and roles"
    task :default_users_roles => :environment do

      puts <<HEREDOC

This task creates four roles (if they don't already exist):

  admin
  researcher
  member
  guest

In addition it create three new default users with these logins:

  admin
  researcher
  member

You can edit the default settings for these users.

HEREDOC

      admin_role = Role.find_or_create_by_title('admin')
      researcher_role = Role.find_or_create_by_title('researcher')
      member_role = Role.find_or_create_by_title('member')
      guest_role = Role.find_or_create_by_title('guest')

      admin_user = User.create(:login => "admin", :email => "admin@concord.org", :password => "password", :password_confirmation => "password", :first_name => "Admin", :last_name => "User")
      researcher_user = User.create(:login => 'researcher', :first_name => 'Researcher', :last_name => 'User', :email => 'researcher@concord.org', :password => "password", :password_confirmation => "password")
      member_user = User.create(:login => 'member', :first_name => 'Member', :last_name => 'User', :email => 'member@concord.org', :password => "password", :password_confirmation => "password")

      edit_user(admin_user).save
      edit_user(researcher_user).save
      edit_user(member_user).save

      admin_user.roles << admin_role 
      researcher_user.roles << researcher_role

      puts
    end
  end
end