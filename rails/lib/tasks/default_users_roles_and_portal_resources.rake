namespace :app do
  namespace :setup do

    require 'fileutils'

    # require 'highline/import'
    autoload :Highline, 'highline'

    def agree_check_in_development_mode
      if ::Rails.env == 'development'
        HighLine.new.agree("Accept defaults? (y/n) ")
      else
        true
      end
    end

    def display_user(user)
      puts <<-HEREDOC

       login: #{user.login}
       email: #{user.email}
  first_name: #{user.first_name}
   last_name: #{user.last_name}

      HEREDOC
    end

    def edit_user(user)
      user.login =                 HighLine.new.ask("            login: ") {|q| q.default = user.login}
      user.email =                 HighLine.new.ask("            email: ") {|q| q.default = user.email}
      user.first_name =            HighLine.new.ask("       first name: ") {|q| q.default = user.first_name}
      user.last_name =             HighLine.new.ask("        last name: ") {|q| q.default = user.last_name}
      user.password =              HighLine.new.ask("         password: ") {|q| q.default = user.password; q.echo = "*"}
      user.password_confirmation = HighLine.new.ask(" confirm password: ") {|q| q.default = user.password_confirmation; q.echo = "*"}
      user
    end

    #######################################################################
    #
    # Create default users, roles, district, school, course, and class, and greade_levels
    #
    #######################################################################   
    desc "Create default users and roles"
    task :create_default_users => :environment do
      require File.expand_path('../../mock_data/create_default_data.rb', __FILE__)
      puts 'Generating default data from default data ymls'
      MockData.create_default_users
    end
    
    desc "Create default classes, teacher class mapping and student class mapping"
    task :create_default_classes => [:environment, :create_default_users] do
      require File.expand_path('../../mock_data/create_default_data.rb', __FILE__)
      MockData.create_default_clazzes
    end
    
    desc "Create default study materials"
    task :create_default_study_materials => [:environment, :create_default_classes] do
      require File.expand_path('../../mock_data/create_default_data.rb', __FILE__)
      MockData.create_default_study_materials
      MockData.create_default_interactives
    end
    
    desc "Create default assignments for classes"
    task :create_default_assignments_for_class => [:environment, :create_default_study_materials] do
      require File.expand_path('../../mock_data/create_default_data.rb', __FILE__)
      MockData.create_default_assignments_for_class
      MockData.create_default_materials_collections
    end
    
    desc "This task creats default learners."
    task :create_default_learners_and_learner_attempts => [:environment, :create_default_assignments_for_class] do
      require File.expand_path('../../mock_data/create_default_data.rb', __FILE__)
      MockData.record_learner_data
    end
    
    desc "Create default data. It is a blank task that calls other task to create default data."
    task :create_default_data => [:environment, :create_default_learners_and_learner_attempts] do
    end
    
    desc "Deletes the default data"
    task :delete_default_data => :environment do
      puts 'Deleting default data'
      require File.expand_path('../../mock_data/delete_default_data.rb', __FILE__)
      MockData.delete_default_data
    end
    
    desc "Resets the default data"
    task :reset_default_data => :environment do
      Rake::Task['app:setup:delete_default_data'].invoke
      Rake::Task['app:setup:create_default_data'].invoke
    end



    task :suspend_default_users => :environment do
      User.suspend_default_users
    end

    task :unsuspend_default_users => :environment do
      User.unsuspend_default_users
    end

    desc "Create Standard Documents"
    task :create_standard_documents => :environment do
      StandardDocument.create_defaults
    end

  end
end
