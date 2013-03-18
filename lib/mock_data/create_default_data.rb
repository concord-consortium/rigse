module MockData
  
  DEFAULT_DATA = YAML.load_file(File.dirname(__FILE__) + "/default_data.yml")
  
  #load all the factories
  Dir[File.dirname(__FILE__) + '/../../factories/*.rb'].each {|file| require file }
  
  
  
  
  def self.convert_hash_keys_to_symbols(hash_to_convert)
    new_hash = {}
    hash_to_convert.reduce('') {|s, (k, v)|
      new_hash[k.to_sym] = v
    }
    new_hash
  end
  
  def self.add_default_user(user_info)
    
    default_password = APP_CONFIG[:password_for_default_users]
    user = nil
    roles = user_info.delete('roles')
    roles = roles ? roles.split(/,\s*/) : []
    
    #TODO: if YAML provides a user password don't override it with the default
    user_info.merge!('password' => default_password)
    
    user_by_uuid = User.find_by_uuid(user_info["uuid"])
    user_by_login = User.find_by_login(user_info["login"])
    
    if user_by_uuid
      user = user_by_uuid
      user.password = user_info['password']
      user.password_confirmation = user_info['password']
      
      user.first_name = user_info['first_name'] if user_info['first_name']
      user.last_name = user_info['last_name'] if user_info['last_name']
      user.email = user_info['email'] if user_info['email']
      
      user.save!
    elsif user_by_login.nil?
      user_info = self.convert_hash_keys_to_symbols(user_info)
      user = Factory(:user, user_info)
      user.save!
      user.confirm!
    end
    
    if user
      roles.each do |role|
        user.add_role(role)
      end
    end
    
    user
  end
  
  #Create fake users and roles
  def self.create_default_users
    
    #create roles in order
    %w| admin manager researcher author member guest|.each_with_index do |role_name,index|
      unless Role.find_by_title_and_position(role_name,index)
        Factory.create(:role, :title => role_name, :position => index)
      end
    end
    
    
    #create a district
    default_district = nil
    district_info = DEFAULT_DATA['district']
    district_by_uuid = Portal::District.find_by_uuid(district_info["uuid"])
    district_by_name = Portal::District.find_by_name(district_info["name"])
    
    if district_by_uuid
      default_district = district_by_uuid
      default_district.name = district_info["name"]
      default_district.description = district_info['description']
      default_district.save!
    elsif district_by_name.nil?
       default_district = Portal::District.create!(district_info)
    end
    
    
    #create schools if default district is present
    default_schools = []
    if default_district
      DEFAULT_DATA['schools'].each do |school, school_info|
        semester_info = school_info.delete("semesters")
        school_by_uuid = Portal::School.find_by_uuid(school_info["uuid"])
        school_by_name_and_district = Portal::School.find_by_name_and_district_id(school_info["name"], default_district.id)
        school = nil
        if school_by_uuid
          school = school_by_uuid
          school.name = school_info['name']
          school.description = school_info['description']
          school.district_id = default_district.id
          school.save!
          default_schools << school
        elsif school_by_name_and_district.nil?
          school_info['district_id'] = default_district.id
          school_info = self.convert_hash_keys_to_symbols(school_info)
          school = Portal::School.create!(school_info)
          default_schools << school
        end
        
        if school
          semester_info.each do |semester, sem_info|
            sem = Portal::Semester.find_or_create_by_uuid(sem_info['uuid'])
            sem.name = sem_info['name']
            sem.school_id = school.id
            sem.save!
          end
        end
      end
    end
    
    
    #following users exist
    default_users = []
    
    DEFAULT_DATA['users'].each do |user, user_info|
      
      user = add_default_user(user_info)
      
      if user
        default_users << user
      end
      
    end
    
    
    #following teachers exist
    
    DEFAULT_DATA['teachers'].each do |teacher, teacher_info|
      
      teacher_school_name = teacher_info.delete('school')
      teacher_school = default_schools.select { |school| school.name == teacher_school_name }
      if teacher_school.length == 0
        next
      else
        teacher_school = teacher_school[0]
      end
      
      
      cohorts = teacher_info.delete("cohort_list")
      
      roles = teacher_info['roles']
      if roles
        roles << 'member'
      else
        roles = ['member']
      end
      teacher_info['roles'] = roles
      
      user = add_default_user(teacher_info)
      
      if user
        portal_teacher = user.portal_teacher
        
        unless portal_teacher
          portal_teacher = Portal::Teacher.create!(:user_id => user.id)
        end
        
        teacher_school.portal_teachers << portal_teacher
        portal_teacher.cohort_list = cohorts if cohorts
        portal_teacher.save!
        
        default_users << user
        
      end
    end
    
    
    
    DEFAULT_DATA['students'].each do |student, student_info|
      
      roles = student_info['roles']
      if roles
        roles << 'member'
      else
        roles = ['member']
      end
      
      student_info['roles'] = roles
      
      user = add_default_user(student_info)
      
      if user
        portal_student = user.portal_student
        unless portal_student
          Portal::Student.create!(:user_id => user.id)
        end
        
        default_users << user
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
