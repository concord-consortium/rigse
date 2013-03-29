module MockData

  #load all the factories
  Dir[File.dirname(__FILE__) + '/../../factories/*.rb'].each {|file| require file }

  def self.default_password=(passwd)
    @default_password=passwd
  end

  def self.default_password
    @default_password ||= ENV['default_password'] || APP_CONFIG[:default_password] || 'password'
  end

  #Create fake users and roles
  def self.create_default_users

    #create roles in order
    %w| admin manager researcher author member guest|.each_with_index do |role_name,index|
      unless Role.find_by_title_and_position(role_name,index)
        Factory.create(:role, :title => role_name, :position => index)
      end
    end


    #create a school
    schools = []
    data = {
       :school_1 => {"name" => 'fake school', "description" => "fake school"},
       :school_2 => {"name" => 'VJTI', "description" => "Tech School"}
    }
    data.each do |school, school_info|
      school = Portal::School.find_by_name(school_info["name"])
      unless school
        school = Factory.create(:portal_school, school_info)
      else
        school.description = school_info["description"]
        school.save!
      end
      schools << school
    end

    #remove all the semesters associated with above school where semester name is null
    schools.each do |school|
      school.semesters.each do |semester|
        if semester.name.blank?
          semester.destroy
        end
      end
    end


    #following semesters exist

    data = {
      :fall => {"name" => 'Fall', "description" => 'Fall Semester', "start_time" => DateTime.new(2012, 12, 01, 00, 00, 00), "end_time" => DateTime.new(2012, 03, 01, 23, 59, 59)},
      :spring => {"name" => 'Spring', "description" => 'Spring Semester', "start_time" => DateTime.new(2012, 10, 10, 23, 59, 59), "end_time" => DateTime.new(2013, 03, 31, 23, 59, 59)},
    }

    schools.each do |school|
      data.each do |semester, semester_info|
        sem  = Portal::Semester.find_by_school_id_and_name(school.id, semester_info["name"])
        unless sem
          sem = Factory.create(:portal_semester, semester_info)
          sem.school = school
          sem.save!
        else
          sem.start_time = semester_info["start_time"]
          sem.end_time = semester_info["end_time"]
          sem.description = semester_info["description"]
          sem.save!
        end
      end
    end


    #following users exist
    data = {
      :user_1 => {"login" => "author", "password" => default_password, "roles" => "member, author"},
      :user_2 => {"login" => "manager", "password" => default_password, "roles" => "manager"},
      :user_3 => {"login" => "mymanager", "password" => default_password, "roles" => "manager"},
      :user_4 => {"login" => "researcher", "password" => default_password, "roles" => "researcher"},
      :user_5 => {"login" => "admin", "password" => default_password, "roles" => "admin"}
    }
    User.anonymous(true)
    data.each do |user, user_info|
      roles = user_info.delete('roles')
      if roles
        roles = roles ? roles.split(/,\s*/) : nil
      else
        roles =  []
      end
      user = User.find_by_login(user_info["login"])
      unless user
        user = Factory(:user, user_info)
        user.save!
        user.confirm!
      else
        user.password = user_info["password"]
        user.password_confirmation = user_info["password"]
      end
      user.save!

      roles.each do |role|
        user.add_role(role)
      end
    end


    #following teachers exist
    data = {
      :teacher_1 => {"login" => 'teacher', "password" => 'password', "first_name" => 'John', "last_name" =>'Nash', "email" => 'bademail@noplace.com', "cohort_list" => "control"},
      :teacher_2 => {"login" => 'albert', "password" => 'password', "first_name" => 'Albert', "last_name" =>'Fernandez', "email" => 'bademail@noplace2.com', "cohort_list" => "experiment"},
      :teacher_3 => {"login" => 'robert', "password" => 'password', "first_name" => 'Robert', "last_name" =>'Fernandez', "email" => 'bademail@noplace3.com', "cohort_list" => "control, experiment"},
      :teacher_4 => {"login" => 'peterson', "password" => 'password', "first_name" => 'peterson', "last_name" =>'taylor', "email" => 'bademail@noplace4.com'},
      :teacher_5 => {"login" => 'teacher_with_no_class', "password" => 'teacher_with_no_class', "first_name"=> 'teacher_with_no_class', "last_name" =>'teacher_with_no_class', "email" => 'bademail@noplace5.com'},
      :teacher_6 => {"login" => 'jonson', "password" => 'password', "first_name" => 'Jonson', "last_name" =>'Jackson', "email" => 'bademail@noplace6.com'}
    }

    data.each do |teacher, teacher_info|
      cohorts = teacher_info.delete("cohort_list")
      user = User.find_by_login(teacher_info["login"])
      unless user
        user = Factory(:user, teacher_info)
        user.add_role("member")
        user.save!
        user.confirm!
      else
        user.password = teacher_info["password"]
        user.password_confirmation = teacher_info["password"]
        user.first_name = teacher_info["first_name"]
        user.last_name = teacher_info["last_name"]
        user.email = teacher_info["email"]
      end
      user.save!

      portal_teacher = user.portal_teacher
      unless portal_teacher
        portal_teacher = Portal::Teacher.create
        portal_teacher.user = user
        #all the teachers belong to fake school
        portal_teacher.schools = [schools[0]]
      end

      portal_teacher.cohort_list = cohorts if cohorts
      portal_teacher.save!
    end


    #Following school and teacher mapping exists
    data = {
      "VJTI" => "teacher, albert",
    }
    data.each do |school, teachers|
      school = Portal::School.find_by_name(school)
      teachers = teachers.split(",").map { |t| t.strip }
      teachers.map! {|t| User.find_by_login(t)}
      teachers.map! {|u| u.portal_teacher }
      teachers.each {|t| t.schools = t.schools + [ school ]; t.save!; t.reload}
    end


    data = {
      :student_1 =>{"login" => "student" ,"password" => default_password ,"first_name" => "Alfred" ,"last_name" => "Robert" ,"email" => "student@mailinator.com" },
      :student_2 =>{"login" => "dave" ,"password" => default_password ,"first_name" => "Dave" ,"last_name" => "Doe" ,"email" => "student@mailinator1.com" },
      :student_3 =>{"login" => "chuck" ,"password" => default_password ,"first_name" => "Chuck" ,"last_name" => "Smith" ,"email" => "student@mailinator2.com" },
      :student_4 =>{"login" => "taylor" ,"password" => default_password ,"first_name" => "taylor" ,"last_name" => "Donald" ,"email" => "student@mailinator3.com" },
      :student_5 =>{"login" => "Mache" ,"password" => default_password ,"first_name" => "Mache" ,"last_name" => "Smith" ,"email" => "student@mailinator4.com" },
      :student_6 =>{"login" => "shon" ,"password" => default_password ,"first_name" => "shon" ,"last_name" => "done" ,"email" => "student@mailinator5.com" },
      :student_7 =>{"login" => "ross" ,"password" => default_password ,"first_name" => "ross" ,"last_name" => "taylor" ,"email" => "student@mailinator6.com" },
      :student_8 =>{"login" => "monty" ,"password" => default_password ,"first_name" => "Monty" ,"last_name" => "Donald" ,"email" => "student@mailinator7.com" },
      :student_9 =>{"login" => "Switchuser" ,"password" => default_password ,"first_name" => "Joe" ,"last_name" => "Switchuser" ,"email" => "student@mailinator8.com" },
    }
    data.each do |student, student_info|
      user = User.find_by_login(student_info["login"])
      unless user
        user = Factory(:user, student_info)
        user.add_role("member")
        user.save!
        user.confirm!
      else
        user.password = student_info["password"]
        user.password_confirmation = student_info["password"]
        user.first_name = student_info["first_name"]
        user.last_name = student_info["last_name"]
        user.email = student_info["email"]
      end

      user.save!
      portal_student = user.portal_student
      unless portal_student
        portal_student = Factory(:full_portal_student, { :user => user})
        portal_student.save!
      end
    end

  end #end of method create_default_users


end # end of MockData