module MockData
  
  DEFAULT_DATA = YAML.load_file(File.dirname(__FILE__) + "/default_data.yml").recursive_symbolize_keys
  
  #load all the factories
  Dir[File.dirname(__FILE__) + '/../../factories/*.rb'].each {|file| require file }
  
  @default_users = nil
  @default_teachers = nil
  @default_students = nil
  @default_courses = nil
  @default_classes = nil
  @default_investigations = nil
  @default_activities = nil
  @default_mcq = nil
  @default_image_question = nil
  
  #Create fake users and roles
  def self.create_default_users
    admin_info = DEFAULT_DATA[:admin_project]
    project = Admin::Project.find_by_uuid(admin_info[:uuid])
    if project
      project.active = false
      project.save!
    else
      Admin::Project.create!(admin_info)
    end
    
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
    @default_classes = default_classes
    
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
  
  
  def self.create_default_study_materials
    # this method creates -
    # multiple choice questions, image questions
    #default investigations, activities, pages and external activities
    
    default_investigations = []
    default_activities = []
    
    @default_investigations = default_investigations
    @default_activities = default_activities
    
    # Resource pages
    DEFAULT_DATA[:resource_pages].each do |key, rp|
      user_name = rp.delete(:user)
      user = @default_users.find{|u| u.login == user_name}
      if user
        default_rp = nil
        rp_by_uuid = ResourcePage.find_by_uuid(rp[:uuid])
        if rp_by_uuid
          default_rp = rp_by_uuid
          default_rp.name = rp[:name]
          default_rp.user_id = user.id
          default_rp.offerings_count = rp[:offerings_count]
          default_rp.created_at = rp[:offerings_count]
          default_rp.publication_status = rp[:publication_status]
          default_rp.save!
        else
          rp[:user_id] = user.id
          resource_page = ResourcePage.create!(rp)
          resource_page.save!
        end
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
      default_mcq = []
      @default_mcq = default_mcq
      
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
        default_mcq << multi_ch_que
      end
    end
    
    if author
      # Image Questions
      default_image_question = []
      @default_image_question = default_image_question
      
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
        
        default_image_question << image_que
      end
    end
    
    
    # Empty Investigations
    
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
        default_investigations << empt_inv if empt_inv
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
        default_investigations << sim_inv if sim_inv
        
      end
    end
    
    # Linked Investigation
    DEFAULT_DATA[:linked_investigations].each do |key, inv|
      user_login = inv.delete(:user)
      user = @default_users.find{|u| u.login == user_login}
      activity_uuid = inv.delete(:activity_uuid)
      section_uuid = inv.delete(:section_uuid)
      page_uuid = inv.delete(:page_uuid)
      open_response_uuid = inv.delete(:open_response_uuid)
      draw_tool_uuid = inv.delete(:draw_tool_uuid)
      lab_book_snapshot = inv.delete(:lab_book_snapshot)
      prediction_graph_uuid = inv.delete(:prediction_graph_uuid)
      displaying_graph_uuid = inv.delete(:displaying_graph_uuid)
      
      if user
        investigation = nil
        inv_by_uuid = Investigation.find_by_uuid(inv[:uuid])
        inv_by_name = Investigation.find_by_name(inv[:name])
        if inv_by_uuid
          investigation = inv_by_uuid
          act = Activity.find_or_create_by_uuid(:uuid => activity_uuid)
          act.user_id = user.id
          act.save!
          investigation.activities << act
          
          sec = Section.find_or_create_by_uuid(:uuid => section_uuid)
          sec.user_id = user.id
          sec.save!
          act.sections << sec
          
          page = Page.find_or_create_by_uuid(:uuid => page_uuid)
          page.user_id = user.id
          sec.save!
          sec.pages << page
          
          open_response = Embeddable::OpenResponse.find_or_create_by_uuid(:uuid => open_response_uuid)
          open_response.user_id = user.id
          open_response.save!
          open_response.pages << page
          
          draw_tool = Embeddable::DrawingTool.find_or_create_by_uuid(:uuid)
          draw_tool.user_id = user.id
          draw_tool.background_image_url = "https://lh4.googleusercontent.com/-xcAHK6vd6Pc/Tw24Oful6sI/AAAAAAAAB3Y/iJBgijBzi10/s800/4757765621_6f5be93743_b.jpg"
          draw_tool.save!
          draw_tool.pages << page
          
          snapshot_button = Embeddable::LabBookSnapshot.find_or_create_by_uuid(lab_book_snapshot)
          snapshot_button.user_id = user.id
          snapshot_button.target_element = draw_tool
          snapshot_button.save!
          snapshot_button << page
          
          prediction_graph = Embeddable::DataCollector.find_or_create_by_uuid(:uuid => prediction_graph_uuid)
          prediction_graph.pages << page
          
          displaying_graph = Embeddable::DataCollector.find_or_create_by_uuid(displaying_graph_uuid)
          displaying_graph.user_id = user.id
          displaying_graph.prediction_graph_id = prediction_graph.id
          displaying_graph.save!
          displaying_graph.pages << page
        else
          inv[:user_id] = user.id
          investigation = Investigation.create!(inv)
          act =  Activity.create!(:user_id => user.id, :uuid => activity_uuid)
          investigation.activities << act
          sec = Section.create!(:user_id => user.id, :uuid => section_uuid)
          act.sections << sec
          page = Page.create!(:user_id => user.id, :uuid => page_uuid)
          sec.pages << page
          
          open_response = Embeddable::OpenResponse.create!(:user_id => user.id, :uuid => open_response_uuid)
          open_response.pages << page
          
          info = {
                   :user_id => user.id,
                   :background_image_url => "https://lh4.googleusercontent.com/-xcAHK6vd6Pc/Tw24Oful6sI/AAAAAAAAB3Y/iJBgijBzi10/s800/4757765621_6f5be93743_b.jpg",
                   :uuid => draw_tool_uuid
                 }
          draw_tool = Embeddable::DrawingTool.create!(info)
          draw_tool.pages << page
          
          info = {
                   :user_id => user.id,
                   :target_element => draw_tool,
                   :uuid => lab_book_snapshot
                 }
          snapshot_button = Embeddable::LabBookSnapshot.create!(info)
          snapshot_button.pages << investigation.activities[0].sections[0].pages[0]
          prediction_graph = Embeddable::DataCollector.create!(:user_id => user.id, :uuid => prediction_graph_uuid)
          prediction_graph.pages << page
          
          info = {
                   :user_id => user.id,
                   :prediction_graph_id => prediction_graph.id,
                   :uuid => displaying_graph_uuid
                 }
          displaying_graph =  Embeddable::DataCollector.create!(info)
          displaying_graph.pages << page
          
        end
        
        default_investigations << investigation if investigation
      end
    end
      
    # investigations with multiple choices exist
    if author
      DEFAULT_DATA[:investigations_with_mcq].each do |key, inv|
        investigation = nil
        inv_by_uuid = Investigation.find_by_uuid(inv[:uuid])
        
        if inv_by_uuid
          investigation = inv_by_uuid
          investigation.name = inv[:name]
          investigation.user_id = author.id
          investigation.save!
          inv[:activities].each do |act, act_info|
            default_pages = []
            
            activity = Activity.find_or_create_by_uuid(act_info[:uuid])
            activity.name = act_info[:name]
            activity.teacher_only = act_info[:activity_teacher_only]
            activity.save!
            
            investigation.activities << activity
            
            act_info[:sections].each do |sec, sec_info|
              section = Section.find_or_create_by_uuid(sec_info[:uuid])
              section.name = sec_info[:name]
              section.save!
              
              activity.sections << section
              
              sec_info[:pages].each do |page, page_info|
                p = Page.find_or_create_by_uuid(page_info[:uuid])
                p.name = page_info[:name]
                p.save!
                
                section.pages << p
                
                default_pages << p
              end
            end
            
            act_info[:multiple_choices].each do |mcq_key, mcq_info|
              mcq = Embeddable::MultipleChoice.find_or_create_by_uuid(mcq_info[:uuid])
              mcq.prompt = mcq_info[:prompt]
              mcq.save!
              
              default_pages.each do |p|
               mcq.pages << p
              end
            end
            
            act_info[:image_questions].each do |imgq_key, imgq_info|
              imgq = Embeddable::ImageQuestion.find_or_create_by_uuid(imgq_info[:uuid])
              imgq.prompt = imgq_info[:prompt]
              imgq.save!
              
              default_pages.each do |p|
               imgq.pages << p
              end
            end
          end
        else
          info = {
                   :name => inv[:name],
                   :uuid => inv[:uuid],
                   :user_id => author.id
                 }
          investigation = Investigation.create!(info)
          
          inv[:activities].each do |act, act_info|
            default_pages = []
            info = {
                     :name => act_info[:name],
                     :uuid => act_info[:uuid],
                     :teacher_only => act_info[:activity_teacher_only]
                   }
            activity = Activity.create!(info)
            
            investigation.activities << activity
            
            act_info[:sections].each do |sec, sec_info|
              info = {
                       :name => sec_info[:name],
                       :uuid => sec_info[:uuid]
                     }
              section = Section.create!(info)
              
              activity.sections << section
              
              sec_info[:pages].each do |page, page_info|
                info = {
                         :name => page_info[:name],
                         :uuid => page_info[:uuid]
                       }
                p = Page.create!(info)
                section.pages << p
                
                default_pages << p
              end
            end
            
            act_info[:multiple_choices].each do |mcq_key, mcq_info|
              mcq = Embeddable::MultipleChoice.find_or_create_by_uuid(mcq_info[:uuid])
              mcq.prompt = mcq_info[:prompt]
              mcq.save!
              
              default_pages.each do |p|
               mcq.pages << p
              end
            end
            
            act_info[:image_questions].each do |imgq_key, imgq_info|
              imgq = Embeddable::ImageQuestion.find_or_create_by_uuid(imgq_info[:uuid])
              imgq.prompt = imgq_info[:prompt]
              imgq.save!
              
              default_pages.each do |p|
               imgq.pages << p
              end
            end
          
          end
        end
        
        default_investigations << investigation if investigation
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
          default_activity.save!
        else
          act[:user_id] = user.id
          act[:investigation_id] = inv.id
          default_activity = Activity.create!(act)
        end
        default_activities << default_activity if default_activity
      end
    end

    # Activities with multiple
    DEFAULT_DATA[:mcq_activities].each do |key, act|
      pages  = []
      user_login = act.delete(:user)
      user = @default_users.find{|u| u.login == user_login}
      if user
        default_activity = nil
        act_by_uuid = Activity.find_by_uuid(act[:uuid])
        if act_by_uuid
          default_activity = act_by_uuid
          default_activity.user_id = user.id
          default_activity.name = act[:name]
          default_activity.description = act[:name]
          default_activity.teacher_only = act[:activity_teacher_only]
          default_activity.save!
          
          act[:sections].each do |sec_key, sec_info|
            sec = Section.find_or_create_by_uuid(sec_info[:uuid])
            sec.name = sec_info[:name]
            sec.save!
            
            # Check if section is added twice if already in array
            default_activity.sections << sec
            
            sec_info[:pages].each do |page_key, p|
              page = Page.find_or_create_by_uuid(p[:uuid])
              page.name = p[:name]
              page.save!
              pages << page
              
              sec.pages << page
            end
          end
          
          act[:multiple_choices].each do |mcq_key, mcq|
            mul_cho_que = Embeddable::MultipleChoice.find_or_create_by_uuid(mcq[:uuid])
            mul_cho_que.prompt = mcq[:prompt]
            mul_cho_que.save!
            
            pages.each do |p|
              mul_cho_que.pages << p
            end
          end
          
          act[:image_questions].each do |iq_key, iq|
            img_que = Embeddable::ImageQuestion.find_or_create_by_uuid(iq[:uuid])
            img_que.prompt = iq[:prompt]
            img_que.save!
            
            pages.each do |p|
              img_que.pages << p
            end
          end
        else
          
          act_info = {
            :name => act[:name],
            :description => act[:name],
            :user_id => user.id,
            :uuid => act[:uuid],
            :teacher_only => act[:activity_teacher_only]
          }
          default_activity = Activity.create!(act_info)
          
          act[:sections].each do |section_key, section|
            sec = Section.create!(:name => section[:name], :uuid => section[:uuid])
            sec.save!
            
            default_activity.sections << sec
            
            section[:pages].each do |page_key, p|
              page = Page.create!(p)
              sec.pages << page
              pages << page
            end
          end
          act[:multiple_choices].each do |mcq_key, mcq|
            mul_cho_que = Embeddable::MultipleChoice.find_or_create_by_uuid(mcq[:uuid])
            mul_cho_que.prompt = mcq[:prompt]
            mul_cho_que.save!
            
            pages.each do |p|
              mul_cho_que.pages << p
            end
          end
          
          act[:image_questions].each do |iq_key, iq|
            img_que = Embeddable::ImageQuestion.find_or_create_by_uuid(iq[:uuid])
            img_que.prompt = iq[:prompt]
            img_que.save!
            
            pages.each do |p|
              img_que.pages << p
            end
          end
        
        end
        
        default_activities << default_activity if default_activity
      end
    end

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
        default_activities << default_ext_act if default_ext_act
      end
    end
    

  end # end of create_study_materials
  
  
  def self.create_default_assignments_for_class
    #this method assigns study materials to the classes
    DEFAULT_DATA[:assignments].each do |assignment_key, assignment|
      clazz = @default_classes.find{|c| c.name == assignment[:class_name]}
      if clazz
        assignment[:assignables].each do |assignable_key, assignable|
          if assignable[:type] == 'Investigation'
            study_material = @default_investigations.find{|i| i.name == assignable[:name]}
          elsif assignable[:type] == 'Activity'
            study_material = @default_activities.find{|a| a.name == assignable[:name]}
          end
        
          if study_material
            default_portal_offering  = Portal::Offering.find_by_clazz_id_and_runnable_id_and_runnable_type(clazz.id, study_material.id, assignable[:type])
            unless default_portal_offering
              default_portal_offering = Factory.create(:portal_offering, { :runnable => study_material,:clazz => clazz})
              default_portal_offering.runnable_type = assignable[:type]
              default_portal_offering.save!
            end
          end
        end
      end
    end
    
  end # end of create_assignments
  
  
  def self.record_learner_data
    # record investigation answers
    investigation_index = 0
    DEFAULT_DATA[:student_answers_investigations].each do |key, res|
      clazz = @default_classes.find{|c| c.name == res[:class]}
      student = @default_students.find{|s| s.user.login == res[:student]}
      investigation = @default_investigations.find{|i| i.name == res[:investigation]}
      if clazz && student && investigation
        res[:class] = clazz
        res[:student] = student
        res[:assignable] = investigation
        res[:index] = investigation_index
        
        res.delete(:investigation)
        
        record_student_answer(res, 'Investigation')
        
        investigation_index = investigation_index + 1
      end
      
    end
    
    # record activity answers
    
    activity_index = 0
    DEFAULT_DATA[:student_answers_activities].each do |key, res|
      clazz = @default_classes.find{|c| c.name == res[:class]}
      student = @default_students.find{|s| s.user.login == res[:student]}
      activity = @default_activities.find{|i| i.name == res[:activity]}
      if clazz && student && activity
        res[:class] = clazz
        res[:student] = student
        res[:assignable] = activity
        res[:index] = activity_index
        
        res.delete(:activity)
        
        record_student_answer(res, 'Activity')
        
        activity_index = activity_index + 1
      end
    end
    
  end # end of record_learner_data
  
  # helper methods
  
  def self.add_default_user(user_info)
    
    default_password = APP_CONFIG[:password_for_default_users]
    user = nil
    user_by_email = nil
    roles = user_info.delete(:roles)
    roles = roles ? roles.split(/,\s*/) : []
    
    #TODO: if YAML provides a user password don't override it with the default
    user_info.merge!(:password => default_password)
    
    user_by_uuid = User.find_by_uuid(user_info[:uuid])
    user_by_login = User.find_by_login(user_info[:login])
    user_by_email = User.find_by_email(user_info[:email]) if user_info[:email]
    
    if user_by_uuid
      user = user_by_uuid
      user.password = user_info[:password]
      user.password_confirmation = user_info[:password]
      
      user.first_name = user_info[:first_name] if user_info[:first_name]
      user.last_name = user_info[:last_name] if user_info[:last_name]
      user.email = user_info[:email] if user_info[:email]
      
      user.save!
    elsif user_by_login.nil? && user_by_email.nil?
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
  
  
  def self.record_student_answer(data, runnable_type)
    index = data.delete(:index)
    first_date = DateTime.now - data.length
    student = data[:student]
    clazz = data[:class]
    assignable = data[:assignable]
    offering = Portal::Offering.find_by_clazz_id_and_runnable_id_and_runnable_type(clazz.id, assignable.id, runnable_type)
    if offering
      learner = offering.find_or_create_learner(student)
      learner.uuid = data[:learner_uuid]
      learner.save!
      
      add_response(learner,data)
      
      report_learner = learner.report_learner
      # need to make sure the last_run is sequencial inorder for some tests to work
      report_learner.last_run = first_date + index
      report_learner.update_fields
    end
  end # end of record_student_answer
  
  
  def self.add_response(learner,data)
    prompts = @default_mcq + @default_image_question
    prompt_text = data[:question_prompt]
    answer_text = data[:answer]
    
    question = prompts.find{|q| q.prompt == prompt_text}
    
    puts "No Question found for #{prompt_text}" if question.nil?
    return if question.nil?
    case question.class.name
    when "Embeddable::MultipleChoice" 
      return add_multichoice_answer(learner,question, answer_text, data)
    when "Embeddable::ImageQuestion"
      return add_image_question_answer(learner,question, answer_text, data)
    end
  end # end of self.add_response


  def self.add_multichoice_answer(learner,question,answer_text, data)
    answer = question.choices.detect{ |c| c.choice == answer_text}
    
    new_answer_by_uuid = Saveable::MultipleChoice.find_by_uuid(data[:saveable_multiple_choices_uuid])
    if new_answer_by_uuid
      new_answer = new_answer_by_uuid
      new_answer.learner = learner
      new_answer.offering = learner.offering
      new_answer.multiple_choice = question
      new_answer.save!
      
      saveable_answer = Saveable::MultipleChoiceAnswer.find_or_create_by_uuid(data[:saveable_multiple_choice_answers_uuid])
      saveable_answer.multiple_choice = new_answer
      saveable_answer.save!
      
      saveable_mc_rationale_choice = Saveable::MultipleChoiceRationaleChoice.find_or_create_by_uuid(data[:saveable_multiple_choice_rationale_choices_uuid])
      saveable_mc_rationale_choice.choice = answer
      saveable_mc_rationale_choice.answer = saveable_answer
      saveable_mc_rationale_choice.save!
    else
      info = {
        :learner => learner,
        :offering => learner.offering,
        :multiple_choice => question,
        :uuid => data[:saveable_multiple_choices_uuid]
      }
      new_answer = Saveable::MultipleChoice.create!(info)
      saveable_answer = Saveable::MultipleChoiceAnswer.create!(:multiple_choice => new_answer, :uuid => data[:saveable_multiple_choice_answers_uuid])
      Saveable::MultipleChoiceRationaleChoice.create(
        :choice => answer,
        :answer => saveable_answer,
        :uuid   => data[:saveable_multiple_choice_rationale_choices_uuid]
      )
    end
    
  end #end of add_multichoice_answer
  
  
  def self.add_image_question_answer(learner,question,answer_text,data)
    return nil if (answer_text.nil? || answer_text.strip.empty?)

    new_answer_by_uuid = Saveable::ImageQuestion.find_by_uuid(data[:saveable_image_question_uuid])
    if new_answer_by_uuid
      new_answer = new_answer_by_uuid
      new_answer.learner = learner
      new_answer.offering = learner.offering
      new_answer.image_question = question
      new_answer.save!
      
      blob = Dataservice::Blob.find_or_create_by_uuid[data[:dataservice_blob_uuid]]
      blob.content = answer_text
      blob.token = answer_text
      blob.save!
      
      saveable_answer = Saveable::ImageQuestionAnswer.find_or_create_by_uuid(data[:saveable_image_question_answer_uuid])
      saveable_answer.blob = blob
      saveable_answer.save!
      
      new_answer.answers << saveable_answer
    else
      info = {
               :learner => learner,
               :offering => learner.offering,
               :image_question => question,
               :uuid => data[:saveable_image_question_uuid]
             }
      
      new_answer = Saveable::ImageQuestion.create!(info)
      
      info = {
               :content => answer_text,
               :token => answer_text,
               :uuid => data[:dataservice_blob_uuid]
             }
      blob = Dataservice::Blob.create!(info)
      
      info = {
               :blob => blob,
               :uuid => data[:saveable_image_question_answer_uuid]
             }
      saveable_answer = Saveable::ImageQuestionAnswer.create!(info)
    end
  end # end add_image_question_answer
  
end # end of MockData
