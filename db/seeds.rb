def create_district_school_semester
  # Make a district
  site_district = Portal::District.find_or_create_by_name(APP_CONFIG[:site_district])
  site_district.description = "This is a virtual district used as a default for Schools, Teachers, Classes and Students that don't belong to any other districts."
  site_district.state = "MA"
  site_district.save!

  # Make a school within the district
  site_school = Portal::School.find_or_create_by_name_and_district_id(APP_CONFIG[:site_school], site_district.id)
  site_school.description = "This is a virtual school used as a default for Teachers, Classes and Students that don't belong to any other schools."
  site_school.state = "MA"
  site_school.save!

  # start with two semesters
  site_school_fall_semester = Portal::Semester.find_or_create_by_name_and_school_id('Fall', site_school.id)
  site_school_spring_semester = Portal::Semester.find_or_create_by_name_and_school_id('Spring', site_school.id)
end

def create_roles
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
end

def create_default_users
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
      :password => "password", :password_confirmation => "password"){|u| u.skip_notifications = true}
  ]

  edit_user_list = default_user_list - [anonymous_user]

  edit_user_list.each { |user| display_user(user) }
 
  default_user_list.each do |user|
    user.save!
    user.unsuspend! if user.state == 'suspended'
    unless user.state == 'active'
      user.confirm!
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

def create_grades
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
end

def create_settings
  settings = Admin::Settings.first
  if settings.nil?
    settings = Admin::Settings.create(:active => true)
  end
end

create_district_school_semester
create_roles
create_default_users
create_grades
create_settings
