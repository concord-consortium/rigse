# npaessel October 6th 2009
# This is a very quick hack to demonstrate integration with our local
# Sakai Instance running on moleman.concord.org.  It is not anticipated that this
# Script should ever be used again.  But it is here for postarity.
# DONT RUN ME.
autoload :Highline, 'highline'
if HighLine.new.agree("create sakai demo accounts? (y/n) ")
  grade_9  = Portal::Grade.find_or_create_by_name(:name => '9',  :description => '9th grade')

  site_district = Portal::District.find_or_create_by_name("RI Sakai District (demo)")
  site_district.description = "This is a virtual district in RI used for testing SAKAI"
  site_district.save!

  site_school = Portal::School.find_or_create_by_name_and_district_id("RI Sakai School (demo)", site_district.id)
  site_school.description = "This is a virtual RI school used for testing sakai integration"
  site_school.save!


  fall_semester = Portal::Semester.find_or_create_by_name_and_school_id('Fall', site_school.id)
  fall_semester.save!

  ##
  ## Setup a course
  ##
  course = Portal::Course.find_or_create_by_name_and_school_id("A+ SOFTWARE 2010 FY Section 1", site_school.id)
  course.grades << grade_9
  course.save!

  
  ##
  ## Setup a clazz
  ##
  attributes = {
    :name => course.name,
    :course_id => course.id,
    :semester_id => fall_semester.id,
    :class_word => 'riteZ1234',
    :description => ''
  }
  unless clazz = Portal::Clazz.find(:first, :conditions => {:name => course.name, :course_id =>course.id})
    clazz = Portal::Clazz.create!(attributes)
  end
  clazz.update_attributes(attributes)
  clazz.status = 'open'
  clazz.save!

  ##
  ## Sakai User Data:
  ##
  default_user_list= [
    teacher_user = User.find_or_create_by_login(:login => 'sderosa2', 
      :first_name => 'Steven', :last_name => 'Derosa', 
      :email => 'knowuh+teacher@gmail.com', 
      :password => "startrek1", :password_confirmation => "startrek1"),

    student1_user = User.find_or_create_by_login(:login => 'kcosta2', 
      :first_name => 'Kaitlyn', :last_name => 'Costa', 
      :email => 'knowuh+student1@gmail.com', 
      :password => "1992-11-30", :password_confirmation => "1992-11-30"),  

    student2_user = User.find_or_create_by_login(:login => 'banderson', 
      :first_name => 'Brian', :last_name => 'Anderson', 
      :email => 'knowuh+student2@gmail.com', 
      :password => "1992-01-12", :password_confirmation => "1992-01-12"),

    student3_user = User.find_or_create_by_login(:login => 'lbaron', 
      :first_name => 'Luke', :last_name => 'Baron', 
      :email => 'knowuh+student3@gmail.com', 
      :password => "1992-07-03", :password_confirmation => "1992-07-03")
  ]
   
  #
  # Ensure that the users are all valid:
  #
  default_user_list.each do |user|
    user.save!
    user.unsuspend! if user.state == 'suspended'
    unless user.state == 'active'
      user.register!
      user.activate!
    end
    user.roles.clear
  end
  
  #
  # Create a Portal::Teacher from the teacher user
  #
  unless teacher = teacher_user.portal_teacher
    teacher = Portal::Teacher.create!(:user_id => teacher_user.id)
  end
  teacher.grades << grade_9
  site_school.members << teacher
  
  #
  # Make the teacher teacher one and only one clazz
  #
  teacher.clazzes.delete_all
  teacher.clazzes << clazz
  clazz.teacher_id = teacher.id
  teacher.reload
  teacher_user.reload

  

  #
  # Set the students up with the clazz
  #
  [student1_user,student2_user,student3_user].each do |user|
    unless student = user.portal_student
      student = Portal::Student.create!(:user_id => user.id)
    end
    site_school.members << student
    student.student_clazzes.delete_all
    student.clazzes << clazz
    student.reload
    user.reload
  end
end

