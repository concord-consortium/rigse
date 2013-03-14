module MockData
  
  DEFAULT_DATA = YAML.load_file(File.dirname(__FILE__) + "/faulty_data.yml")
  
  #load all the factories
  Dir[File.dirname(__FILE__) + '/../../factories/*.rb'].each {|file| require file }
  
  #Create fake users and roles
  def self.create_default_users
    
    password = APP_CONFIG[:default_users_password]
    #create roles in order
    %w| admin manager researcher author member guest|.each_with_index do |role_name,index|
      unless Role.find_by_title_and_position(role_name,index)
        Factory.create(:role, :title => role_name, :position => index)
      end
    end
    
    
    #create a school
    schools = []
    
    DEFAULT_DATA['schools'].each do |school, school_info|
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
    
    
    
    schools.each do |school|
      DEFAULT_DATA['semesters'].each do |semester, semester_info|
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
    
    User.anonymous(true)
    DEFAULT_DATA['users'].each do |user, user_info|
      roles = user_info.delete('roles')
      user_info.merge!('password' => password)
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
        user.password = user_info['password']
        user.password_confirmation = user_info['password']
      end
      user.save!
      
      roles.each do |role|
        user.add_role(role)
      end
    end
    
    
    #following teachers exist
    
    DEFAULT_DATA['teachers'].each do |teacher, teacher_info|
      cohorts = teacher_info.delete("cohort_list")
      teacher_info.merge!('password' => password)
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
    
    DEFAULT_DATA['school_teacher_mapping'].each do |school, teachers|
      school = Portal::School.find_by_name(school)
      teachers = teachers.split(",").map { |t| t.strip }
      teachers.map! {|t| User.find_by_login(t)}
      teachers.map! {|u| u.portal_teacher }
      teachers.each {|t| t.schools = t.schools + [ school ]; t.save!; t.reload}
    end
    
    
    
    DEFAULT_DATA['students'].each do |student, student_info|
      user = User.find_by_login(student_info["login"])
      student_info.merge!('password' => password)
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
  
  def self.create_default_clazzes

    # this method creates default classes,
    # teacher class mapping
    # student class mapping
    
    #following classes exist:
    DEFAULT_DATA['classes'].each do |claz, clazz_info|
      user = User.find_by_login clazz_info['teacher']
      teacher = user.portal_teacher
      clazz_info.merge!('teacher' => teacher)
      
      clazz = Portal::Clazz.find_by_class_word(clazz_info['class_word'])
      if clazz
        clazz.name = clazz_info['name']
        clazz.add_teacher(teacher)
      else
      Factory.create(:portal_clazz, clazz_info)
      end
    end
    
    #following teacher and class mapping exists:
    DEFAULT_DATA['teacher_clazzes'].each do |teacher, clazzes_name|
      user = User.find_by_login(teacher)
      portal_teacher = Portal::Teacher.find_by_user_id(user.id)
      clazzes_name = clazzes_name.split(",").map{|c| c.strip }
      clazzes = clazzes_name.map!{|c| Portal::Clazz.find_by_name(c)}
      clazzes.each do |clazz|
        teacher_clazz = Portal::TeacherClazz.find_by_clazz_id_and_teacher_id(clazz.id, portal_teacher.id)
        unless teacher_clazz
          teacher_clazz = Portal::TeacherClazz.new()
          teacher_clazz.clazz_id = clazz.id
          teacher_clazz.teacher_id = portal_teacher.id
          save_result = teacher_clazz.save!
        end
      end
    end
    
    #And following student clazz mapping exist
    DEFAULT_DATA['student_clazzes'].each do |student_name, clazzes|
      student = User.find_by_login(student_name).portal_student
      clazzes = clazzes.split(",").map{|c| c.strip }
      clazzes.map!{|c| Portal::Clazz.find_by_name(c)}
      clazzes.each do |each_clazz|
        student_clazz = Portal::StudentClazz.find_by_student_id_and_clazz_id(student.id, each_clazz.id)
        unless student_clazz
          Factory.create :portal_student_clazz, :student => student, :clazz => each_clazz
        end
      end
    end

  end #end of create_default_clazzes
end # end of MockData
