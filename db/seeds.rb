# Make a district
site_district = Portal::District.find_or_create_by_name(APP_CONFIG[:site_district])
site_district.description = "This is a virtual district used as a default for Schools, Teachers, Classes and Students that don't belong to any other districts."
site_district.save!

# Make a school within the district
site_school = Portal::School.find_or_create_by_name_and_district_id(APP_CONFIG[:site_school], site_district.id)
site_school.description = "This is a virtual school used as a default for Teachers, Classes and Students that don't belong to any other schools."
site_school.save!

# Make a User
teacher_user = User.find_or_create_by_login(:login => 'teacher',
  :first_name => 'Valerie', :last_name => 'Frizzle',
  :email => 'teacher@concord.org',
  :password => "password", :password_confirmation => "password"){|u| u.skip_notifications = true}
teacher_user.register! if teacher_user.activated_at.nil?
teacher_user.activate! if teacher_user.activated_at.nil?

# Give the teacher a role of 'member'
teacher_user.add_role('member')
teacher_user.save!

# Make a Portal::Teacher with the user's id
teacher = Portal::Teacher.find_or_create_by_user_id(:user_id => teacher_user.id)
site_school.portal_teachers << teacher

["purple", "green", "orange", "yellow"].each do |color|
  # Make Portal::Clazzes with the teacher's id
  clazz = Portal::Clazz.find_or_create_by_class_word(:name => color, :teacher_id => teacher.id, :class_word => color)
  clazz.teacher = teacher
  clazz.save!

  # Make 50 users
  (1..50).each do |num|
    u = User.find_or_create_by_login(:login => "#{color}#{num}",
    :first_name             => "#{color}#{num}",
    :email                  => "#{color}#{num}@example.com",
    :password               => "#{color}#{num}",
    :password_confirmation  => "#{color}#{num}"){|u| u.skip_notifications = true}
    u.register! if u.activated_at.nil?
    u.activate! if u.activated_at.nil?

    # Make a student with the user's id
    student = Portal::Student.find_or_create_by_user_id(:user_id => u.id)

    # Append the class to the student's classes
    student.clazzes << clazz
    student.save!
    site_school.add_member student
  end
end
