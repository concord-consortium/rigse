module MockData
  
  DEFAULT_DATA = YAML.load_file(File.dirname(__FILE__) + "/default_data.yml")
  
  #load all the factories
  Dir[File.dirname(__FILE__) + '/../../factories/*.rb'].each {|file| require file }
  
  @default_users = nil
  @default_teachers = nil
  @default_students = nil
  @default_courses = nil
  
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
    district_info = DEFAULT_DATA[:district]
    district_by_uuid = Portal::District.find_by_uuid(district_info[:uuid])
    district_by_name = Portal::District.find_by_name(district_info[:name])
    
    if district_by_uuid
      default_district = district_by_uuid
      default_district.name = district_info[:name]
      default_district.description = district_info[:description]
      default_district.save!
    elsif district_by_name.nil?
       default_district = Portal::District.create!(district_info)
    end
    
    #create default grades
    default_grades = []
    DEFAULT_DATA[:grades].each do |grade, grade_info|
      portal_grade = Portal::Grade.find_by_uuid(grade_info[:uuid])
      if portal_grade
        portal_grade.name = grade_info[:name]
        portal_grade.description = grade_info[:description]
        portal_grade.save!
      else
        portal_grade = Factory.create(:portal_grade, grade_info)
      end
      default_grades << portal_grade
    end
    
    #create default grades levels
    default_grades_levels = []
    DEFAULT_DATA[:grade_levels].each do |grade, grade_level_info|
      portal_grade = default_grades.find{|g| g.name == grade_level_info[:grade]}
      if portal_grade
        portal_grade_level = Portal::GradeLevel.find_by_uuid(grade_level_info[:uuid])
        if portal_grade_level
          portal_grade_level.grade_id = portal_grade.id
          portal_grade_level.name = grade_level_info[:name]
          portal_grade_level.save!
        else
          grade_level_info.delete(:grade)
          grade_level_info[:grade_id] = portal_grade.id
          portal_grade_level = Portal::GradeLevel.create!(grade_level_info)
        end
        default_grades_levels << portal_grade_level
      end
    end
    
    
    #create schools if default district is present
    default_schools = []
    if default_district
      DEFAULT_DATA[:schools].each do |school, school_info|
        
        semester_info = school_info.delete(:semesters)
        grade_levels_info = school_info.delete(:grade_levels)
        grade_levels = grade_levels_info.split(',').map{|c| c.strip }
        
        school_by_uuid = Portal::School.find_by_uuid(school_info[:uuid])
        school_by_name_and_district = Portal::School.find_by_name_and_district_id(school_info[:name], default_district.id)
        school = nil
        
        if school_by_uuid
          school = school_by_uuid
          school.name = school_info[:name]
          school.description = school_info[:description]
          school.district_id = default_district.id
          school.save!
        elsif school_by_name_and_district.nil?
          school_info[:district_id] = default_district.id
          school = Portal::School.create!(school_info)
        end
        
        if school
          semester_info.each do |semester, sem_info|
            sem = Portal::Semester.find_or_create_by_uuid(sem_info[:uuid])
            sem.name = sem_info[:name]
            sem.school_id = school.id
            sem.save!
          end
          
          grade_levels.map! { |gl| default_grades_levels.find { |dgl| dgl.name == gl } }
          grade_levels.compact
          
          school.grade_levels = grade_levels
          
          default_schools << school
        end
      end
    end
    
    
    #following courses exist
    default_courses = []
    DEFAULT_DATA[:courses].each do |course, course_info|
      school = default_schools.find{|s| s.name == course_info[:school]}
      if school
        default_course = Portal::Course.find_by_uuid(course_info[:uuid])
        if default_course
          default_course.name = course_info[:name]
          default_course.school_id = school.id
          default_course.save!
        else
          course_info.delete(:school)
          course_info[:school_id] = school.id
          default_course = Portal::Course.create(course_info)
        end
        
        default_courses << default_course
      end
    end
    
    @default_courses = default_courses
    
    #following users exist
    default_users = []
    @default_users = default_users
    
    DEFAULT_DATA[:users].each do |user, user_info|
      
      user = add_default_user(user_info)
      
      if user
        default_users << user
      end
      
    end
    
    
    #following teachers exist
    default_teachers = []
    @default_teachers = default_teachers
    
    DEFAULT_DATA[:teachers].each do |teacher, teacher_info|
      
      teacher_school_name = teacher_info.delete(:school)
      teacher_school = default_schools.select { |school| school.name == teacher_school_name }
      if teacher_school.length == 0
        next
      else
        teacher_school = teacher_school[0]
      end
      
      
      cohorts = teacher_info.delete(:cohort_list)
      
      roles = teacher_info[:roles]
      if roles
        roles << 'member'
      else
        roles = ['member']
      end
      teacher_info[:roles] = roles
      
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
        default_teachers << portal_teacher
      end
    end
    
    
    default_students = []
    @default_students = default_students
    DEFAULT_DATA[:students].each do |student, student_info|
      
      roles = student_info[:roles]
      if roles
        roles << 'member'
      else
        roles = ['member']
      end
      
      student_info[:roles] = roles
      
      user = add_default_user(student_info)
      
      if user
        portal_student = user.portal_student
        unless portal_student
          portal_student = Portal::Student.create!(:user_id => user.id)
        end
        
        default_users << user
        default_students << portal_student
      end
    end
    
    
    
    
  end #end of method create_default_users
  
  def self.create_default_clazzes

    # this method creates default classes,
    # teacher class mapping
    # student class mapping
    
    #following classes exist:
    default_classes = []
    DEFAULT_DATA[:classes].each do |clazz, clazz_info|
      course = @default_courses.find{|c| c.name == clazz_info[:course]}
      clazz_info.delete(:course)
      if course 
        default_clazz = nil
        default_clazz_by_uuid = Portal::Clazz.find_by_uuid(clazz_info[:uuid])
        default_clazz_by_clazz_word = Portal::Clazz.find_by_class_word(clazz_info[:class_word])
        teacher = @default_teachers.find{|t| t.user.login == clazz_info[:teacher]}
        
        if default_clazz_by_uuid
          unless default_clazz_by_clazz_word
            default_clazz = default_clazz_by_uuid
            default_clazz.clazz_word = clazz_info[:class_word]
            default_clazz.teacher_id = teacher.id
            default_clazz.course_id = course.id
            default_clazz.save!
            teacher.add_clazz(default_clazz)
          end
        elsif teacher and default_clazz_by_clazz_word.nil?
          clazz_info.delete(:teacher)
          clazz_info[:teacher_id] = teacher.id
          clazz_info[:course_id] = course.id
          default_clazz = Portal::Clazz.create!(clazz_info)
          teacher.add_clazz(default_clazz)
        end
        
        default_classes << default_clazz if default_clazz
      end
    end
    
    #following teacher and class mapping exists:
    DEFAULT_DATA[:teacher_clazzes].each do |teacher_clazz, teacher_clazz_info|
      map_teacher = @default_teachers.find{|t| t.user.login == teacher_clazz_info[:teacher]}
      if map_teacher
        clazz_names = teacher_clazz_info[:clazz_names].split(",").map{|c| c.strip }
        clazz_names.each do |clazz_name|
          map_clazz = default_classes.find{|c| c.name == clazz_name}
          if map_clazz
            teacher_clazz = Portal::TeacherClazz.find_or_create_by_teacher_id_and_clazz_id(map_teacher.id, map_clazz.id)
          end
        end
      end
    end
    
    #And following student class mapping exist
    DEFAULT_DATA[:student_clazzes].each do |student_clazz, student_clazz_info|
      map_student = @default_students.find{|s| s.user.login == student_clazz_info[:student]}
      if map_student
        clazz_names = student_clazz_info[:clazz_names].split(",").map{|c| c.strip }
        clazz_names.each do |clazz_name|
          map_clazz = default_classes.find{|c| c.name == clazz_name}
          if map_clazz
            student_clazz = Portal::StudentClazz.find_or_create_by_student_id_and_clazz_id(map_student.id, map_clazz.id)
          end
        end
      end
    end

  end #end of create_default_clazzes
  
  
  def self.create_study_materials
    # this method creates -
    # multiple choice questions, image questions
    #default investigations, activities, pages and external activities
    
    #TODO Populate default_investigations where ever you create investigations
    default_investigations = []
    
    # Resource pages
    DEFAULT_DATA[:resource_pages].each do |key, rp|
      user_name = rp.delete(:user)
      user = @default_users.find{|u| u.login == user_name}
      if user
        rp[:user_id] = user.id
        resource_page = ResourcePage.create!(rp)
        resource_page.save!
      end
    end
    
    # pages
    DEFAULT_DATA[:pages].each do |key, p|
      user_name = p.delete(:user)
      user = @default_users.find{|u| u.login == user_name}
      if user
        default_page = nil
        page_by_uuid = Page.find_by_uuid(p[:uuid])
        if page_by_uuid
          default_page = page_by_uuid
          default_page.name = p[:name]
          default_page.user = user
          default_page.publication_status = p[:publication_status]
        else
          p[:user_id] = user.id
          Page.create!(p)
        end
      end
    end
    
    # Multiple Choice questions
    author = @default_users.find{|u| u.login == 'author'}
    if author
      DEFAULT_DATA[:mult_cho_questions].each do |key,mcq|
        choices = mcq.delete(:answers)
        choices = choices.split(',')
        choices.map!{|c| c.strip}
        correct = mcq.delete(:correct_answer)
        
        multi_ch_que = nil
        mcq_by_uuid =  Embeddable::MultipleChoice.find_by_uuid(mcq[:uuid])
        
        if mcq_by_uuid
          multi_ch_que = mcq_by_uuid
          multi_ch_que.prompt = mcq[:prompt]
          multi_ch_que.save!
        else
          mcq[:user_id] = author.id
          multi_ch_que = Embeddable::MultipleChoice.create!(mcq)
          
          choices.map! { |c| Embeddable::MultipleChoiceChoice.create(
            :choice => c, 
            :multiple_choice_id => multi_ch_que.id,
            :is_correct => (c == correct)
          )}
          
          multi_ch_que.choices = choices
        end
      end
    end
    
    if author
      # Image Questions
      DEFAULT_DATA[:image_questions].each do |key, imgq|
        image_que = nil
        imgq_by_uuid = Embeddable::ImageQuestion.find_by_uuid(imgq[:uuid])
        if imgq_by_uuid
          image_que = imgq_by_uuid
          image_que.user_id = author.id
          image_que.prompt = imgq[:uuid]
          image_que.save!
        else
          imgq[:user_id] = author.id
          image_que = Embeddable::ImageQuestion.create!(imgq)
        end
      end
    end
    
    
    # Empty Investigations
    default_investigations = []
    DEFAULT_DATA[:empty_investigations].each do |key, inv|
      user_login = inv.delete(:user)
      user = @default_users.find{|u| u.login == user_login}
      if user
        empt_inv = nil
        inv_by_uuid = Investigation.find_by_uuid(inv[:uuid])
        inv_by_name = Investigation.find_by_name(inv[:name])
        if inv_by_uuid
          empt_inv = inv_by_uuid
          empt_inv.name = inv[:name]
          empt_inv.user_id = user.id
          empt_inv.offerings_count = inv[:offerings_count]
          empt_inv.publication_status = empt_inv.publication_status
          empt_inv.created_at = inv[:created_at] if inv[:created_at]
          empt_inv.save!
        else
          inv[:user_id] = user.id 
          empt_inv = Investigation.create!(inv)
        end
        default_investigations if empt_inv
      end
    end
    
    
    # Simple Investigation
    DEFAULT_DATA[:simple_investigations].each do |key, inv|
      user_login = inv.delete(:user)
      user = @default_users.find{|u| u.login == user_login}
      
      activity_uuid = inv.delete(:activity_uuid)
      section_uuid = inv.delete(:section_uuid)
      page_uuid = inv.delete(:page_uuid)
      
      if user
        sim_inv = nil
        inv_by_uuid = Investigation.find_by_uuid(inv[:uuid])
        inv_by_name = Investigation.find_by_name(inv[:name])
        if inv_by_uuid
          sim_inv = inv_by_uuid
          
          act = Activity.find_or_create_by_uuid(:activity_uuid)
          sec = Section.find_or_create_by_uuid(:section_uuid)
          page = Page.find_or_create_by_uuid(:page_uuid)
          
          [sim_inv, act, sec, page].each do |obj|
            sim_inv.name = inv[:name]
            sim_inv.user_id = user.id
            sim_inv.offerings_count = inv[:offerings_count]
            sim_inv.publication_status = inv[:publication_status]
          end
        else
          inv[:user_id] = user.id
          sim_inv = Investigation.create!(inv)
          activity = Activity.create(inv)
          section = Section.create(inv)
          page = Page.create(inv)
          section.pages << page
          activity.sections << section
          sim_inv.activities << activity
          sim_inv.save!
        end
        default_investigations if sim_inv
        
      end
    end
    
    # Activities for the above investigations exist
    DEFAULT_DATA[:activities].each do |key, act|
      inv_name = act.delete(:investigation)
      user_login = act.delete(:user)
      user = @default_users.find{|u| u.login == user_login}
      inv = default_investigations.find{|i| i.name == inv_name}
      if inv and user
        default_activity = nil
        act_by_uuid = Activity.find_by_uuid(act[:uuid])
        
        if act_by_uuid
          default_activity = act_by_uuid
          default_activity.user_id = user.id
          default_activity.name = act[:name]
          default_activity.investigation_id = inv.id
        else
          act[:user_id] = user.id
          act[:investigation_id] = inv.id
          default_activity = Activity.create!(act)
        end
      end
    end
=begin    
    # Activities with multiple
    DEFAULT_DATA[:mcq_activities].each do |key, act|
      pages  = []
      user_login = act.delete(:user)
      user = @default_user.find{|u| u.login == user_login}
      if user
        default_activity = nil
        act_by_uuid = Activity.find_by_uuid(act[:uuid])
        if act_by_uuid
          default_activity = act_by_uuid
          default_activity.user_id = user.id
          default_activity.name = act[:activity]
          default_activity.save!
          
          default_activity[:sections].each do |section|
            sec = Section.find_or_create_by_uuid(section[:uuid])
            sec.name = section[:name]
            sec.save!
            
            default_activity.sections << sec
            
            section[:pages].each do |p|
              page = Page.find_or_create_by_uuid(p[:uuid])
              page.name = p[:name]
              page.save!
              pages << page
              
              sec.pages << page
            end
          end
          
          act[:multiple_choices].each do |mcq|
            mul_cho_que = Embeddable::MultipleChoice.find_or_create_by_uuid(mcq[:uuid])
            mul_cho_que.prompt = mcq[:prompt]
            mul_cho_que.save!
            
            pages.each do |p|
              mul_cho_que.pages << p
            end
          end
          
          act[:image_questions].each do |iq|
            img_que = Embeddable::ImageQuestion.find_or_create_by_uuid(mcq[:uuid])
            img_que.prompt = mcq[:prompt]
            img_que.save!
            
            pages.each do |p|
              mul_cho_que.pages << p
            end
          end
        end
      else
        defaut_activity = Activity.create!(:uuid => act[:uuid], :name => act[:name])
        pages = []
        default_activity[:sections].each do |section|
          sec = Section.create!(:name => section[:name], :uuid => section[:uuid])
          sec.save!
          
          defaut_activity.section << sec
          
          section[:pages].each |p|
            page = Page.create!(:name = p[:name], :uuid => p[:uuid])
            sec.pages << page
            pages << page
          end
        end
        act[:multiple_choices].each do |mcq|
            mul_cho_que = Embeddable::MultipleChoice.find_or_create_by_uuid(mcq[:uuid])
            mul_cho_que.prompt = mcq[:prompt]
            mul_cho_que.save!
            
            pages.each do |p|
              mul_cho_que.pages << p
            end
          end
          
          act[:image_questions].each do |iq|
            img_que = Embeddable::ImageQuestion.find_or_create_by_uuid(mcq[:uuid])
            img_que.prompt = mcq[:prompt]
            img_que.save!
            
            pages.each do |p|
              mul_cho_que.pages << p
            end
          end
      end
    end
=end
    # External Activity
    DEFAULT_DATA[:external_activities].each do |key, act|
      user_login = act.delete(:user)
      user = @default_users.find{|u| u.login == user_login}
      if user
        default_ext_act = nil
        act_by_uuid = Activity.find_by_uuid(act[:uuid])
        if act_by_uuid
          default_ext_act = act_by_uuid
          default_ext_act.user_id = user.id
          default_ext_act.url = act[:url]
          default_ext_act.name = act[:name]
          default_ext_act.save!
        else
          act[:user_id] = user.id
          default_ext_act = ExternalActivity.create!(act)
          default_ext_act.publish
          default_ext_act.save!
        end
      end
    end
    

  end
  
  
  # helper methods
  
  def self.add_default_user(user_info)
    
    default_password = APP_CONFIG[:password_for_default_users]
    user = nil
    roles = user_info.delete(:roles)
    roles = roles ? roles.split(/,\s*/) : []
    
    #TODO: if YAML provides a user password don't override it with the default
    user_info.merge!(:password => default_password)
    
    user_by_uuid = User.find_by_uuid(user_info[:uuid])
    user_by_login = User.find_by_login(user_info[:login])
    
    if user_by_uuid
      user = user_by_uuid
      user.password = user_info[:password]
      user.password_confirmation = user_info[:password]
      
      user.first_name = user_info[:first_name] if user_info[:first_name]
      user.last_name = user_info[:last_name] if user_info[:last_name]
      user.email = user_info[:email] if user_info[:email]
      
      user.save!
    elsif user_by_login.nil?
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
end # end of MockData
