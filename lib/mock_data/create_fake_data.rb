module MockData
  require File.expand_path('../../../spec/spec_helper.rb', __FILE__)
  #load all the factories
  Dir[File.dirname(__FILE__) + '/../../factories/*.rb'].each {|file| require file }
  
  #Create fake users and roles
  def self.create_default_users
  
    #create roles in order
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
    
    
    #following semesters exist
    data = {
      :fall => {"name" => 'Fall', "start_time" => DateTime.new(2012, 12, 01, 00, 00, 00), "end_time" => DateTime.new(2012, 03, 01, 23, 59, 59) },
      :spring => {"name" => 'Spring', "start_time" => DateTime.new(2012, 10, 10, 23, 59, 59), "end_time" => DateTime.new(2013, 03, 31, 23, 59, 59) } 
    }
    
    data.each do |semester, semester_info|
     Factory.create(:portal_semester, semester_info)
    end
    

    #following teachers exist
    data = {
      :teacher_1 => {"login" => 'teacher', "password" => 'teacher', "first_name" => 'John', "last_name" =>'Nash', "email" => 'bademail@noplace.com'},
      :teacher_2 => {"login" => 'albert', "password" => 'albert', "first_name" => 'Albert', "last_name" =>'Fernandez', "email" => 'bademail@noplace2.com'},
      :teacher_3 => {"login" => 'robert', "password" => 'robert', "first_name" => 'Robert', "last_name" =>'Fernandez', "email" => 'bademail@noplace3.com'},
      :teacher_4 => {"login" => 'peterson', "password" => 'teacher', "first_name" => 'peterson', "last_name" =>'taylor', "email" => 'bademail@noplace4.com'},
      :teacher_5 => {"login" => 'teacher_with_no_class', "password" => 'teacher_with_no_class', "first_name"=> 'teacher_with_no_class', "last_name" =>'teacher_with_no_class', "email" => 'bademail@noplace5.com'},
      :teacher_6 => {"login" => 'jonson', "password" => 'teacher', "first_name" => 'Jonson', "last_name" =>'Jackson', "email" => 'bademail@noplace6.com'}
    }
    
    semester = Portal::Semester.first
    school = Factory.create(:portal_school, :semesters => [semester])
    course = Factory.create(:portal_course, :school => school)
    clazz = Factory.create(:portal_clazz, :course => course)
    User.anonymous(true)
    data.each do |teacher, teacher_info|
      begin
        cohorts = teacher_info.delete("cohort_list")
        user = Factory(:user, teacher_info)
        user.add_role("member")
        user.register
        user.activate
        user.save!
        
        portal_teacher = Portal::Teacher.create(:user_id => user.id)
        portal_teacher.schools = [school]
        portal_teacher.clazzes = [clazz]
        portal_teacher.cohort_list = cohorts if cohorts
        portal_teacher.save!
        
      rescue ActiveRecord::RecordInvalid
        # assume this user is already created...
      end
    end
    
 
    #following users exist
    data = {
      :user_1 => {"login" => "author", "password" => "author", "roles" => "member, author"},
      :user_2 => {"login" => "myadmin", "password" => "myadmin", "roles" => "admin"},
      :user_3 => {"login" => "manager", "password" => "manager", "roles" => "manager"},
      :user_4 => {"login" => "mymanager", "password" => "mymanager", "roles" => "manager"},
      :user_5 => {"login" => "researcher", "password" => "researcher", "roles" => "researcher"},
      :user_6 => {"login" => "admin", "password" => "password", "roles" => "admin"}
    }
    
    User.anonymous(true)
    data.each do |user, user_info|
      roles = user_info.delete('roles')
      if roles
        roles = roles ? roles.split(/,\s*/) : nil
      else
        roles =  []
      end
      begin
        user = Factory(:user, user_info)
        roles.each do |role|
          user.add_role(role)
        end
        user.register
        user.activate
        user.save!
      rescue ActiveRecord::RecordInvalid
        # assume this user is already created...
      end
    end
    
    
    #following students exist:
    data = {
      :student_1 =>{"login" => "student" ,"password" => "student" ,"first_name" => "Alfred" ,"last_name" => "Robert" ,"email" => "student@mailinator.com" },
      :student_2 =>{"login" => "dave" ,"password" => "student" ,"first_name" => "Dave" ,"last_name" => "Doe" ,"email" => "student@mailinator1.com" },
      :student_3 =>{"login" => "chuck" ,"password" => "student" ,"first_name" => "Chuck" ,"last_name" => "Smith" ,"email" => "student@mailinator2.com" },
      :student_4 =>{"login" => "taylor" ,"password" => "student" ,"first_name" => "taylor" ,"last_name" => "Donald" ,"email" => "student@mailinator3.com" },
      :student_5 =>{"login" => "Mache" ,"password" => "student" ,"first_name" => "Mache" ,"last_name" => "Smith" ,"email" => "student@mailinator4.com" },
      :student_6 =>{"login" => "shon" ,"password" => "student" ,"first_name" => "shon" ,"last_name" => "done" ,"email" => "student@mailinator5.com" },
      :student_7 =>{"login" => "ross" ,"password" => "student" ,"first_name" => "ross" ,"last_name" => "taylor" ,"email" => "student@mailinator6.com" },
      :student_8 =>{"login" => "monty" ,"password" => "student" ,"first_name" => "Monty" ,"last_name" => "Donald" ,"email" => "student@mailinator7.com" },
      :student_9 =>{"login" => "Switchuser" ,"password" => "Switchuser" ,"first_name" => "Joe" ,"last_name" => "Switchuser" ,"email" => "student@mailinator8.com" },
    }
    User.anonymous(true)
    portal_grade = Factory.create(:portal_grade)
    portal_grade_level = Factory.create(:portal_grade_level, {:grade => portal_grade})
    data.each do |student, student_info|
      begin
        clazz = Portal::Clazz.find_by_name(student_info.delete('class'))
        user = Factory(:user, student_info)
        user.add_role("member")
        user.register
        user.activate
        user.save!
  
        portal_student = Factory(:full_portal_student, { :user => user, :grade_level =>  portal_grade_level})
        portal_student.save!
        if (clazz)
          portal_student.add_clazz(clazz)
        end
      rescue ActiveRecord::RecordInvalid
        # assume this user is already created...
      end
    end
    
  end #end of method create_default_users

end # end of MockData