def create_district_school
  # Make a district
  site_district = Portal::District.where(name: APP_CONFIG[:site_district]).first_or_create
  site_district.description = "This is a virtual district used as a default for Schools, Teachers, Classes and Students that don't belong to any other districts."
  site_district.state = "MA"
  site_district.save!

  # Make a school within the district
  site_school = Portal::School.where(name: APP_CONFIG[:site_school], district_id: site_district.id).first_or_create
  site_school.description = "This is a virtual school used as a default for Teachers, Classes and Students that don't belong to any other schools."
  site_school.state = "MA"
  site_school.save!

end

def create_roles
  roles_in_order = [
    Role.where(title: 'admin').first_or_create,
    Role.where(title: 'manager').first_or_create,
    Role.where(title: 'researcher').first_or_create,
    Role.where(title: 'author').first_or_create,
    Role.where(title: 'member').first_or_create,
    Role.where(title: 'guest').first_or_create
  ]

  all_roles = Role.all
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
    admin_user = User.where(:login => default_admin_user_settings [:login]).first_or_create(
      :first_name => default_admin_user_settings[:first_name],
      :last_name =>  default_admin_user_settings[:last_name],
      :email =>      default_admin_user_settings[:email],
      :password => "password", :password_confirmation => "password"){|u| u.skip_notifications = true},

    manager_user = User.where(:login => 'manager').first_or_create(
      :first_name => 'Manager', :last_name => 'User',
      :email => 'manager@concord.org',
      :password => "password", :password_confirmation => "password"){|u| u.skip_notifications = true},

    researcher_user = User.where(:login => 'researcher').first_or_create(
      :first_name => 'Researcher', :last_name => 'User',
      :email => 'researcher@concord.org',
      :password => "password", :password_confirmation => "password"){|u| u.skip_notifications = true},

    author_user = User.where(:login => 'author').first_or_create(
      :first_name => 'Author', :last_name => 'User',
      :email => 'author@concord.org',
      :password => "password", :password_confirmation => "password"){|u| u.skip_notifications = true},

    member_user = User.where(:login => 'member').first_or_create(
      :first_name => 'Member', :last_name => 'User',
      :email => 'member@concord.org',
      :password => "password", :password_confirmation => "password"){|u| u.skip_notifications = true},

    anonymous_user = User.anonymous,

    teacher_user = User.where(:login => 'teacher').first_or_create(
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
  author_user.add_role('author')
  member_user.add_role('member')
  anonymous_user.add_role('guest')

  teacher = Portal::Teacher.where(:user_id => teacher_user.id).first_or_create
  site_school = Portal::School.find_by_name(APP_CONFIG[:site_school])
  site_school.portal_teachers << teacher
end

def create_grades
  grades_in_order = [
  grade_k  = Portal::Grade.where(:name => 'K').first_or_create( :description => 'kindergarten'),
  grade_1  = Portal::Grade.where(:name => '1').first_or_create( :description => '1st grade'),
  grade_2  = Portal::Grade.where(:name => '2').first_or_create( :description => '2nd grade'),
  grade_3  = Portal::Grade.where(:name => '3').first_or_create( :description => '3rd grade'),
  grade_4  = Portal::Grade.where(:name => '4').first_or_create( :description => '4th grade'),
  grade_5  = Portal::Grade.where(:name => '5').first_or_create( :description => '5th grade'),
  grade_6  = Portal::Grade.where(:name => '6').first_or_create( :description => '6th grade'),
  grade_7  = Portal::Grade.where(:name => '7').first_or_create( :description => '7th grade'),
  grade_8  = Portal::Grade.where(:name => '8').first_or_create( :description => '8th grade'),
  grade_9  = Portal::Grade.where(:name => '9').first_or_create( :description => '9th grade'),
  grade_10 = Portal::Grade.where(:name => '10').first_or_create(:description => '10th grade'),
  grade_11 = Portal::Grade.where(:name => '11').first_or_create(:description => '11th grade'),
  grade_12 = Portal::Grade.where(:name => '12').first_or_create(:description => '12th grade')
  ]

  # to make sure the list is ordered correctly in case a new grade level is added
  grades_in_order.each_with_index do |grade, i|
    grade.insert_at(i)
  end
end

def create_settings
  settings = Admin::Settings.first
  if settings.nil?
    Admin::Settings.create(:active => true)
  end
end

def create_default_lara_report
  auth_client = Client.where(name: "DEFAULT_REPORT_SERVICE_CLIENT").first_or_create(
    app_id: "DEFAULT_REPORT_SERVICE_CLIENT",
    app_secret: SecureRandom.uuid(),
    domain_matchers: ".*\.concord\.org localhost.*",
    type: "public"
  )

  ExternalReport.where(name: "DEFAULT_REPORT_SERVICE").first_or_create(
    url: "http://portal-report.concord.org/branch/master/index.html",
    launch_text: "Report",
    client_id: auth_client.id,
    report_type: "offering",
    allowed_for_students: true,
    default_report_for_source_type: "LARA",
    individual_student_reportable: true,
    individual_activity_reportable: true
  )

  # To support Activity Player publishing you need to manually add a Tool with the tool_id of https://activity-player.concord.org. 
  # The convention is the source_type is ActivityPlayer.
end

create_district_school
create_roles
create_default_users
create_grades
create_settings
create_default_lara_report

# populate Countries table
Portal::Country.from_csv_file

#
# Populate default Standard Documents
#
StandardDocument.create_defaults
