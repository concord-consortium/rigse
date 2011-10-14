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
    task :default_users_roles => :environment do

      # some constants that should probably be moved to settings.yml
      DEFAULT_CLASS_NAME = 'Fun with Investigations'
      
      puts <<-HEREDOC

This task creates six roles (if they don't already exist):

  admin
  manager
  researcher
  author
  member
  guest

It creates one user with an admin role. 

  The default values for the admin user are taken from config/settings.yml.
  Edit the values in this file if you want to specify a different default admin user.

In addition it creates seven more default users with these login names and the 
default password: 'password'. You can change the default password if you wish.

  manager
  researcher
  author
  member
  teacher
  student
  anonymous

You can edit the default settings for all of these users.

It also creates one published Investigation owned by the Author user.

It also create a default School District: '#{APP_CONFIG[:site_district]}'.
and a default School in that district: '#{APP_CONFIG[:site_school]}'.

The default Teacher user will be a Teacher in the school: #{APP_CONFIG[:site_school]} and
will be teaching a course named 'Fun with Investigations' and a class in that course named '#{DEFAULT_CLASS_NAME}'

A student named: 'Student User' will be created and will be a learner in the default class: '#{DEFAULT_CLASS_NAME}'.

First creating admin user account for: #{APP_CONFIG[:admin_email]} from site parameters in config/settings.yml:
      HEREDOC

      roles_in_order = [
        admin_role = Role.find_or_create_by_title('admin'),
        manager_role = Role.find_or_create_by_title('manager'),
        researcher_role = Role.find_or_create_by_title('researcher'),
        author_role = Role.find_or_create_by_title('author'),
        member_role = Role.find_or_create_by_title('member'),
        guest_role = Role.find_or_create_by_title('guest')
      ]
      
      all_roles = Role.find(:all)
      unused_roles = all_roles - roles_in_order
      if unused_roles.length > 0
        unused_roles.each { |role| role.destroy }
      end
      
      # to make sure the list is ordered correctly in case a new role is added
      roles_in_order.each_with_index do |role, i|
        role.insert_at(i)
      end

      default_admin_user_settings = APP_CONFIG[:default_admin_user]

      default_user_list = [
        admin_user = User.find_or_create_by_login(:login => default_admin_user_settings [:login], 
          :first_name => default_admin_user_settings[:first_name], 
          :last_name =>  default_admin_user_settings[:last_name],
          :email =>      default_admin_user_settings[:email], 
          :password => "password", :password_confirmation => "password"){|u| u.skip_notifications = true},

        manager_user = User.find_or_create_by_login(:login => 'manager', 
          :first_name => 'Manager', :last_name => 'User', 
          :email => 'manager@concord.org', 
          :password => "password", :password_confirmation => "password"){|u| u.skip_notifications = true},

        researcher_user = User.find_or_create_by_login(:login => 'researcher', 
          :first_name => 'Researcher', :last_name => 'User', 
          :email => 'researcher@concord.org', 
          :password => "password", :password_confirmation => "password"){|u| u.skip_notifications = true},

        author_user = User.find_or_create_by_login(:login => 'author', 
          :first_name => 'Author', :last_name => 'User', 
          :email => 'author@concord.org', 
          :password => "password", :password_confirmation => "password"){|u| u.skip_notifications = true},

        member_user = User.find_or_create_by_login(:login => 'member', 
          :first_name => 'Member', :last_name => 'User', 
          :email => 'member@concord.org', 
          :password => "password", :password_confirmation => "password"){|u| u.skip_notifications = true},

        anonymous_user = User.anonymous,

        teacher_user = User.find_or_create_by_login(:login => 'teacher', 
          :first_name => 'Valerie', :last_name => 'Frizzle', 
          :email => 'teacher@concord.org', 
          :password => "password", :password_confirmation => "password"){|u| u.skip_notifications = true},

        student_user = User.find_or_create_by_login(:login => 'student', 
          :first_name => 'Jackie', :last_name => 'Demeter', 
          :email => 'student@concord.org', 
          :password => "password", :password_confirmation => "password"){|u| u.skip_notifications = true}
      ]

      edit_user_list = default_user_list - [anonymous_user]
      
      edit_user_list.each { |user| display_user(user) }
      
      unless agree_check_in_development_mode
        edit_user_list.each do |user|
          user = edit_user(user)  if HighLine.new.agree("Edit #{user.login}?  (y/n) ")
        end
      end

      default_user_list.each do |user|
        user.save!
        user.unsuspend! if user.state == 'suspended'
        unless user.state == 'active'
          user.register!
          user.activate!
        end
        user.roles.clear
      end
      
      # Setting the default_user boolean allows suspending and unsuspending
      # the whole group of default_users like this:
      #
      #   User.suspend_default_users
      #
      #   User.unsuspend_default_users
      #
      # The anonymous users is a proxy user for vistitors who are
      # not logged in so it is not in the class of default users
      # who can be suspended.
      #
      # The admin user is based on the user specified in settings.yml and
      # also can't be suspended.
      #
      suspendable_default_users = default_user_list - [anonymous_user, admin_user]
      suspendable_default_users.each do |user|
        user.default_user = true
        user.save!
      end

      User.suspend_default_users unless APP_CONFIG[:enable_default_users]

      admin_user.add_role('admin')
      
      # Set the site_admin attribute to true for the site_admin.
      # This will be used more later for performance reasons as 
      # we integrate permission_sets into membership models.
      admin_user.update_attribute(:site_admin, true)
      
      manager_user.add_role('manager')
      researcher_user.add_role('researcher')
      teacher_user.add_role('member')
      member_user.add_role('member')
      anonymous_user.add_role('guest')
    end
    
    
    #######################################################################
    #
    # Create default portal resources: district, school, course, and class, investigation and grades
    #
    #######################################################################   
    desc "Create default portal resources"
    task :default_portal_resources => :environment do

      # some constants that should probably be moved to settings.yml
      DEFAULT_CLASS_NAME = 'Fun with Investigations'

      author_user = User.find_by_login('author')
      teacher_user = User.find_by_login('teacher')
      student_user = User.find_by_login('student')
      
      default_investigation = DefaultRunnable.create_default_runnable_for_user(author_user)

      grades_in_order = [
        grade_k  = Portal::Grade.find_or_create_by_name(:name => 'K',  :description => 'kindergarten'),
        grade_1  = Portal::Grade.find_or_create_by_name(:name => '1',  :description => '1st grade'),
        grade_2  = Portal::Grade.find_or_create_by_name(:name => '2',  :description => '2nd grade'),
        grade_3  = Portal::Grade.find_or_create_by_name(:name => '3',  :description => '3rd grade'),
        grade_4  = Portal::Grade.find_or_create_by_name(:name => '4',  :description => '4th grade'),
        grade_5  = Portal::Grade.find_or_create_by_name(:name => '5',  :description => '5th grade'),
        grade_6  = Portal::Grade.find_or_create_by_name(:name => '6',  :description => '6th grade'),
        grade_7  = Portal::Grade.find_or_create_by_name(:name => '7',  :description => '7th grade'),
        grade_8  = Portal::Grade.find_or_create_by_name(:name => '8',  :description => '8th grade'),
        grade_9  = Portal::Grade.find_or_create_by_name(:name => '9',  :description => '9th grade'),
        grade_10 = Portal::Grade.find_or_create_by_name(:name => '10', :description => '10th grade'),
        grade_11 = Portal::Grade.find_or_create_by_name(:name => '11', :description => '11th grade'),
        grade_12 = Portal::Grade.find_or_create_by_name(:name => '12', :description => '12th grade')
      ]

      # to make sure the list is ordered correctly in case a new grade level is added
      grades_in_order.each_with_index do |grade, i|
        grade.insert_at(i)
      end

      # make a default district and school
      site_district = Portal::District.find_or_create_by_name(APP_CONFIG[:site_district])
      site_district.description = "This is a virtual district used as a default for Schools, Teachers, Classes and Students that don't belong to any other districts."
      site_district.save!
      site_school = Portal::School.find_or_create_by_name_and_district_id(APP_CONFIG[:site_school], site_district.id)
      site_school.description = "This is a virtual school used as a default for Teachers, Classes and Students that don't belong to any other schools."
      site_school.save!

      # start with two semesters
      site_school_fall_semester = Portal::Semester.find_or_create_by_name_and_school_id('Fall', site_school.id)
      site_school_spring_semester = Portal::Semester.find_or_create_by_name_and_school_id('Spring', site_school.id)
  
      # default course
      # This model is currently underdeveloped and not implemented into the app properly 
      # Use the default class name for now
      site_school_default_course = Portal::Course.find_or_create_by_name_and_school_id(DEFAULT_CLASS_NAME, site_school.id)
      site_school_default_course.grades << grade_9
      
      # default_school_teacher = teacher_user.portal_teacher.find_or_create_by_school_id(site_school.id)
      unless default_school_teacher = teacher_user.portal_teacher
        default_school_teacher = Portal::Teacher.create!(:user_id => teacher_user.id)
      end
      default_school_teacher.grades << grade_9
      
      site_school.portal_teachers << default_school_teacher
      
      # default_school_teacher.courses << site_school_default_course

      # default class
      attributes = {
        :name => DEFAULT_CLASS_NAME,
        :course_id => site_school_default_course.id,
        :semester_id => site_school_fall_semester.id,
        :teacher_id => default_school_teacher.id,
        :class_word => 'abc123',
        :description => 'This is a default class created for the default school ... etc'
      }
      unless default_course_class = 
        Portal::Clazz.find_by_class_word(attributes[:class_word]) ||
        Portal::Clazz.find_by_name_and_teacher_id(attributes[:name], attributes[:teacher_id])
        default_course_class = Portal::Clazz.create!(attributes)
      else
        default_course_class.update_attributes!(attributes)
      end
      default_course_class.status = 'open'
      default_course_class.teacher = default_school_teacher
      default_course_class.save!
      
      # default offering
      attributes = {
        :clazz_id => default_course_class.id,
        :runnable_id => default_investigation.id,
        :runnable_type => default_investigation.class.name
      }
      unless offering = Portal::Offering.find(:first, :conditions => attributes)
        offering = Portal::Offering.create!(attributes)
      end
      offering.status = 'active'
      offering.save

      # default student
      attributes = {
        :user_id => student_user.id,
        :grade_level_id => grade_9.id
      }
      unless default_student = Portal::Student.find(:first, :conditions => attributes)
        default_student = Portal::Student.create!(attributes)
      end
      default_student.student_clazzes.delete_all
      default_student.clazzes << default_course_class
      site_school.add_member(default_student)
      #
      # default_student = student_user.student || student_user.student.create!
      # 
      # To make a new learner you need an existing student and offering -- presumably
      # an offering that the student is not already a learner in.
      #
      # >> u = User.find_by_login('student'); s = u.portal_student; o = Portal::Offering.find(:first)
      # => #<Portal::Offering id: 51, uuid: "5158a04a-888a-11de-8336-001ff3caa767", status: "active", clazz_id: 7, runnable_id: 510, runnable_type: "Investigation", created_at: "2009-08-14 04:24:12", updated_at: "2009-08-14 04:24:12">
      # >> a = { :student_id => s.id, :offering_id => o.id }; default_learner = Portal::Learner.find(:first, :conditions => a)
      # => nil
      # >> l = o.learners.create(:student => s)
      # => #<Portal::Learner id: 238, uuid: "fc3a0a62-88df-11de-872e-001ff3caa767", student_id: 1, offering_id: 51, created_at: "2009-08-14 14:37:26", updated_at: "2009-08-14 14:37:26", bundle_logger_id: nil, console_logger_id: nil>
      #
      # When moving from older versions of learner objects (before 20090814)
      # to newer ones check whether the learner has defined valid_loggers?
      # and if not, use the instance method Learner#create_new_loggers to create
      # them
      #
      attributes = {
        :student_id => default_student.id,
        :offering_id => offering.id
      }
      if default_learner = Portal::Learner.find(:first, :conditions => attributes)
        unless default_learner.valid_loggers?
          default_learner.create_new_loggers
        end
      else
        offering.learners.create(:student => default_student)
      end
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

      admin_user = User.create(:login => APP_CONFIG[:admin_login], :email => APP_CONFIG[:admin_email], :password => "password", :password_confirmation => "password", :first_name => APP_CONFIG[:admin_first_name], :last_name => APP_CONFIG[:admin_last_name])
      researcher_user = User.create(:login => 'researcher', :first_name => 'Researcher', :last_name => 'User', :email => 'researcher@concord.org', :password => "password", :password_confirmation => "password")
      member_user = User.create(:login => 'member', :first_name => 'Member', :last_name => 'User', :email => 'member@concord.org', :password => "password", :password_confirmation => "password")
      anonymous_user = User.create(:login => "anonymous", :email => "anonymous@concord.org", :password => "password", :password_confirmation => "password", :first_name => "Anonymous", :last_name => "User")

      [admin_user, researcher_user, member_user].each do |user|
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
    # Delete existing users and restore default users and roles
    #
    #######################################################################   
    desc "Delete existing users and restore default users and roles"
    task :delete_users_and_restore_default_users_roles => :environment do
      # The TRUNCATE cammand works in mysql to effectively empty the database and reset 
      # the autogenerating primary key index ... not certain about other databases
      puts
      puts "deleted: #{ActiveRecord::Base.connection.delete("TRUNCATE `#{User.table_name}`")} from User"
      Rake::Task['app:setup:default_users_roles_and_portal_resources'].invoke
      Rake::Task['app:setup:create_additional_users'].invoke
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
    #     "login" => "stephen",
    #     "email"=>"stephen.bannasch@gmail.com"}
    #   }
    # File.open(File.join(::Rails.root.to_s, %w{config additional_users.yml}), 'w') {|f| YAML.dump(additional_users, f)}
    # 
    # The additional users will be created but each one will need to go to the
    # forgot password link to actually get a working password:
    #
    #   http://rigse-dev.concord.org/rigse/forgot_password
    #
    desc "Create additional users from additional_users.yml file."
    task :create_additional_users => :environment do
      begin
        path = File.join(::Rails.root.to_s, %w{config additional_users.yml})
        additional_users = YAML::load(IO.read(path))
        puts "\nCreating additional users ...\n\n"
        pw = User.make_token
        additional_users.each do |user_config|
          puts "  #{user_config[1]['role']} #{user_config[0]}: #{user_config[1]['first_name']} #{user_config[1]['last_name']}, #{user_config[1]['login']}, #{user_config[1]['email']}"
          if u = User.find_by_email(user_config[1]['email'])
            puts "  *** user: #{u.name} already exists ...\n"
          else
            u = User.create(:login => user_config[0], 
              :first_name => user_config[1]['first_name'], 
              :last_name => user_config[1]['last_name'], 
              :login => user_config[1]['login'], 
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
        end
        puts "\n"
      rescue SystemCallError => e
        # puts e.class
        # puts "#{path} not found"
      end
    end

    desc "create an investigation to test all know probe_type / calibration combinations"
    task "create_probe_testing_investigation" => :environment do
      author_user = User.find_by_login("author")
      if author_user
        DefaultRunnable.recreate_sensor_testing_investigation_for_user(author_user)
      else
        puts "You must have created the default author user first"
        puts "try running the default_users_roles task"
      end
    end
  end
end
