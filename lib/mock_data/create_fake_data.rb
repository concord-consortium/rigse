module MockData
  
  #load all the factories
  Dir[File.dirname(__FILE__) + '/../../factories/*.rb'].each {|file| require file }
  
  #Create fake users and roles
  def self.create_default_users
    
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
      :teacher_5 => {"login" => 'teacher_with_no_class', "password" => 'teacher_with_no_class', "first_name"=> 'teacher_with_no_class', "last_name" =>'teacher_with_no_class', "email" => 'bademail@noplace5.com'}
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
      :user_6 => {"login" => "admin", "password" => "admin", "roles" => "admin"},
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
  end #end of method create_default_users

end # end of MockData