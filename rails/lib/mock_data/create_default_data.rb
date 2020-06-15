module MockData

  current_dir = File.dirname(__FILE__)
  default_data = {}

  default_data_yaml_files = Dir.glob(current_dir + '/default_data_yaml/*')

  default_data_yaml_files.each do |file|
    current_file_data = YAML.load_file(file)
    default_data.merge!(current_file_data)
  end

  DEFAULT_DATA = default_data.recursive_symbolize_keys

  @default_users = nil
  @default_teachers = nil
  @default_students = nil
  @default_courses = nil
  @default_classes = nil
  @default_investigations = nil
  @default_activities = nil
  @default_external_activities = nil
  @default_mcq = nil
  @default_image_question = nil

  #Create fake users and roles
  def self.create_default_users
    puts
    puts
    admin_info = DEFAULT_DATA[:admin_settings]
    settings = Admin::Settings.find_by_uuid(admin_info[:uuid])
    if settings
      settings.active = false
      settings.save!
      puts
      puts 'Updated default settings'
    else
      Admin::Settings.create!(admin_info)
      puts
      puts 'Generated default settings'
    end

    puts
    puts
    create_count = 0
    update_count = 0

    DEFAULT_DATA[:roles].each do |i, role|
      role_by_uuid = Role.find_by_uuid(role[:uuid])
      if role_by_uuid
        r = role_by_uuid
        r.title = role[:title]
        r.save!

        update_count += 1
        print '+'
      else
        role_by_title = Role.find_by_title(role[:title])
        unless role_by_title
          last_role = Role.all.last
          unless last_role
            max_pos = 0
          else
            max_pos = last_role.position + 1
          end
          new_role = Role.create!(role)
          new_role.position = max_pos
          new_role.save!

          create_count += 1
          print '.'
        else
          puts
          puts "Skipping role '#{role_by_title.title}' as it already exists"
        end
      end
    end

    puts
    puts "Generated #{create_count} and updated #{update_count} roles"

    #create a district
    puts
    puts
    default_district = nil
    district_info = DEFAULT_DATA[:district]
    district_by_uuid = Portal::District.find_by_uuid(district_info[:uuid])
    district_by_name = Portal::District.find_by_name(district_info[:name])

    if district_by_uuid
      default_district = district_by_uuid
      default_district.name = district_info[:name]
      default_district.description = district_info[:description]
      default_district.save!

      puts
      puts "Updated '#{default_district.name}' district"
    elsif district_by_name.nil?
      default_district = Portal::District.create!(district_info)

      puts
      puts "Generated '#{default_district.name}' district"
    else
      puts
      puts "Skipping district #{default_district.name} as it already exists"
    end

    #create default grades
    puts
    puts
    default_grades = []

    create_count = 0
    update_count = 0

    DEFAULT_DATA[:grades].each do |grade, grade_info|
      portal_grade = Portal::Grade.find_by_uuid(grade_info[:uuid])
      if portal_grade
        portal_grade.name = grade_info[:name]
        portal_grade.description = grade_info[:description]
        portal_grade.save!

        update_count += 1
        print '+'
      else
        portal_grade = FactoryBot.create(:portal_grade, grade_info)

        create_count += 1
        print '.'
      end
      default_grades << portal_grade
    end
    puts
    puts "Generated #{create_count} and updated #{update_count} portal grades"

    #create default grades levels
    puts
    puts
    default_grades_levels = []

    create_count = 0
    update_count = 0

    DEFAULT_DATA[:grade_levels].each do |grade, grade_level_info|
      portal_grade = default_grades.find{|g| g.name == grade_level_info[:grade]}
      if portal_grade
        portal_grade_level = Portal::GradeLevel.find_by_uuid(grade_level_info[:uuid])
        if portal_grade_level
          portal_grade_level.grade_id = portal_grade.id
          portal_grade_level.name = grade_level_info[:name]
          portal_grade_level.save!

          update_count += 1
          print '+'
        else
          grade_level_info.delete(:grade)
          grade_level_info[:grade_id] = portal_grade.id
          portal_grade_level = Portal::GradeLevel.create!(grade_level_info)

          create_count += 1
          print '.'
        end
        default_grades_levels << portal_grade_level
      end
    end
    puts
    puts "Generated #{create_count} and updated #{update_count} portal grade levels"

    #create schools if default district is present



    puts
    puts

    default_schools = []

    create_count = 0
    update_count = 0

    if default_district
      DEFAULT_DATA[:schools].each do |school, school_info|

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

          update_count += 1
          print '+'
        elsif school_by_name_and_district.nil?
          school_info[:district_id] = default_district.id
          school = Portal::School.create!(school_info)

          create_count += 1
          print '.'
        end

        if school

          grade_levels.map! { |gl| default_grades_levels.find { |dgl| dgl.name == gl } }
          grade_levels.compact

          school.grade_levels = grade_levels

          default_schools << school
        end
      end
      puts
      puts "Generated #{create_count} and updated #{update_count} portal schools"
    end


    #following courses exist



    puts
    puts

    default_courses = []

    create_count = 0
    update_count = 0

    DEFAULT_DATA[:courses].each do |course, course_info|
      school = default_schools.find{|s| s.name == course_info[:school]}
      if school
        default_course = Portal::Course.find_by_uuid(course_info[:uuid])
        if default_course
          default_course.name = course_info[:name]
          default_course.school_id = school.id
          default_course.save!

          update_count += 1
          print '+'
        else
          course_info.delete(:school)
          course_info[:school_id] = school.id
          default_course = Portal::Course.create(course_info)

          create_count += 1
          print '.'
        end
        default_courses << default_course
      end
    end
    puts
    puts "Generated #{create_count} and updated #{update_count} portal courses"

    @default_courses = default_courses

    #following users exist
    puts
    puts
    default_users = []
    @default_users = default_users

    create_count = 0
    update_count = 0

    # create the anonymous user
    User.anonymous

    DEFAULT_DATA[:users].each do |user, user_info|

      user_data = add_default_user(user_info)

      unless user_data[:skipped?]

        if user_data[:created?]
          create_count += 1
          print '.'
        elsif user_data[:updated?]
          update_count += 1
          print '+'
        end

        default_users << user_data[:user]
      else
        puts
        puts "Skipped user '#{user_info[:login]}' as it already exists (conflict user id: #{user_data[:conflicting_user]})"
      end

    end
    puts
    puts "Generated #{create_count} and updated #{update_count} users"

    #following teachers exist
    puts
    puts
    default_teachers = []
    @default_teachers = default_teachers

    create_count = 0
    update_count = 0

    DEFAULT_DATA[:teachers].each do |teacher, teacher_info|

      teacher_school_name = teacher_info.delete(:school)
      teacher_school = default_schools.select { |school| school.name == teacher_school_name }
      if teacher_school.length == 0
        next
      else
        teacher_school = teacher_school[0]
      end


      cohorts_names = teacher_info.delete(:cohort_names) || ''
      cohorts = cohorts_names.split(' ').map { |name| Admin::Cohort.create!(:name => name) }

      roles = teacher_info[:roles]
      if roles
        roles << 'member'
      else
        roles = ['member']
      end
      teacher_info[:roles] = roles

      user_data = add_default_user(teacher_info)

      unless user_data[:skipped?]
        user = user_data[:user]
        portal_teacher = user.portal_teacher

        if user_data[:created?]
          create_count += 1
          print '.'
        elsif user_data[:updated?]
          update_count += 1
          print '+'
        end

        unless portal_teacher
          portal_teacher = Portal::Teacher.create!(:user_id => user.id)
        end

        teacher_school.portal_teachers << portal_teacher
        portal_teacher.cohorts = cohorts
        portal_teacher.save!

        default_users << user
        default_teachers << portal_teacher
      else
        puts
        puts "Skipped teacher user '#{teacher_info[:login]}' as it already exists (conflict user id: #{user_data[:conflicting_user]})"
      end
    end
    puts
    puts "Generated #{create_count} and Updated #{update_count} teachers"


    puts
    puts
    default_students = []
    @default_students = default_students

    create_count = 0
    update_count = 0

    DEFAULT_DATA[:students].each do |student, student_info|

      roles = student_info[:roles]
      if roles
        roles << 'member'
      else
        roles = ['member']
      end

      student_info[:roles] = roles

      user_data = add_default_user(student_info)

      unless user_data[:skipped?]
        user = user_data[:user]
        portal_student = user.portal_student

        if user_data[:created?]
          create_count += 1
          print '.'
        elsif user_data[:updated?]
          update_count += 1
          print '+'
        end


        unless portal_student
          portal_student = Portal::Student.create!(:user_id => user.id)
        end

        default_users << user
        default_students << portal_student
      else
        puts
        puts "Skipped student user '#{student_info[:login]}' as it already exists (conflict user id: #{user_data[:conflicting_user]})"
      end
    end
    puts
    puts "Generated #{create_count} and Updated #{update_count} students"



  end #end of method create_default_users

  def self.create_default_clazzes
    # this method creates default classes,
    # teacher class mapping
    # student class mapping

    #following classes exist:
    puts
    puts
    create_count = 0
    update_count = 0
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
          unless default_clazz_by_clazz_word.uuid != default_clazz_by_uuid.uuid
            default_clazz = default_clazz_by_uuid
            default_clazz.name = clazz_info[:name]
            default_clazz.class_word = clazz_info[:class_word]
            default_clazz.teacher_id = teacher.id
            default_clazz.course_id = course.id
            default_clazz.save!
            teacher.add_clazz(default_clazz)
            update_count += 1
            print '+'
          else
            puts "Skipping Class #{default_clazz_by_uuid.name} as class word #{clazz_info[:class_word]} is already taken"
          end
        elsif teacher and default_clazz_by_clazz_word.nil?
          clazz_info.delete(:teacher)
          clazz_info[:teacher_id] = teacher.id
          clazz_info[:course_id] = course.id
          default_clazz = Portal::Clazz.create!(clazz_info)
          teacher.add_clazz(default_clazz)
          create_count = create_count + 1
          print '.'
        else
          puts "Skipping Class because teacher or class word were not proper."
        end
        default_classes << default_clazz if default_clazz
      end
    end
    puts
    puts "Generated #{create_count} and updated #{update_count} Classes"

    #following teacher and class mapping exists:
    DEFAULT_DATA[:teacher_clazzes].each do |teacher_clazz, teacher_clazz_info|
      map_teacher = @default_teachers.find{|t| t.user.login == teacher_clazz_info[:teacher]}
      if map_teacher
        clazz_names = teacher_clazz_info[:clazz_names].split(",").map{|c| c.strip }
        clazz_names.each do |clazz_name|
          map_clazz = default_classes.find{|c| c.name == clazz_name}
          if map_clazz
            teacher_clazz = Portal::TeacherClazz.where(teacher_id: map_teacher.id, clazz_id: map_clazz.id).first_or_create
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
            student_clazz = Portal::StudentClazz.where(student_id: map_student.id, clazz_id: map_clazz.id).first_or_create
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
    default_external_activities = []
    @default_investigations = default_investigations
    @default_activities = default_activities
    @default_external_activities = default_external_activities
    # pages
    puts
    puts
    create_count = 0
    update_count = 0
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
          update_count += 1
          print '+'
        else
          p[:user_id] = user.id
          Page.create!(p)
          create_count += 1
          print '.'
        end
      end
    end
    puts
    puts "Generated #{create_count} and updated #{update_count} Pages"


    # Multiple Choice questions
    puts
    puts
    create_count = 0
    update_count = 0
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
          update_count += 1
          print "+"
        else
          mcq[:user_id] = author.id
          multi_ch_que = Embeddable::MultipleChoice.create!(mcq)

          choices.map! { |c| Embeddable::MultipleChoiceChoice.create(
            :choice => c,
            :multiple_choice_id => multi_ch_que.id,
            :is_correct => (c == correct)
          )}

          multi_ch_que.choices = choices

          print '.'
          create_count += 1
        end
        default_mcq << multi_ch_que
      end
      puts
      puts "Generated #{create_count} and updated #{update_count} Multiple Choice questions"
    end


    puts
    puts
    create_count = 0
    update_count = 0
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
          update_count += 1
          print '+'
        else
          imgq[:user_id] = author.id
          image_que = Embeddable::ImageQuestion.create!(imgq)
          create_count += 1
          print '.'
        end

        default_image_question << image_que
      end
      puts
      puts "Generated #{create_count} and updated #{update_count} Image questions"
    end



    # External Activity
    puts
    puts
    create_count = 0
    update_count = 0
    DEFAULT_DATA[:external_activities].each do |key, act|
      user_login = act.delete(:user)
      user = @default_users.find{|u| u.login == user_login}
      if user
        default_ext_act = nil
        act_by_uuid = ExternalActivity.find_by_uuid(act[:uuid])
        if act_by_uuid
          default_ext_act = act_by_uuid
          default_ext_act.user_id = user.id
          default_ext_act.url = act[:url]
          default_ext_act.name = act[:name]
          default_ext_act.author_email = user.email
          default_ext_act.is_official = true
          default_ext_act.save!
          update_count += 1
          print '+'
        else
          make_template = act.delete(:make_template)
          sub_activities = act.delete(:activities)
          act[:user_id] = user.id
          act[:author_email] = user.email
          default_ext_act = ExternalActivity.create!(act)
          default_ext_act.template = FactoryBot.create(:activity,
            name: default_ext_act.name,
            description: default_ext_act.long_description
          )
          if(sub_activities)
            investigation = FactoryBot.create(:investigation,
              name: default_ext_act.name,
              description: default_ext_act.long_description
            )
            acts = sub_activities.each do |a|
              investigation.activities.create(name: a)
            end
            default_ext_act.template = investigation
          end
          default_ext_act.publish
          default_ext_act.is_official = true
          default_ext_act.save!
          create_count += 1
          print '.'
        end
        default_external_activities << default_ext_act if default_ext_act
      end
    end
    puts
    puts "Generated #{create_count} and updated #{update_count} External Activities"

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
          elsif assignable[:type] == 'ExternalActivity'
            study_material = @default_external_activities.find{|a| a.name == assignable[:name]}
          end
          if study_material
            offering_uuid = assignable[:offering_uuid]

            default_portal_offering  = Portal::Offering.find_by_clazz_id_and_runnable_id_and_runnable_type(clazz.id, study_material.id, assignable[:type])
            if default_portal_offering
              default_portal_offering.uuid = offering_uuid
              default_portal_offering.save!
            else
              default_portal_offering = FactoryBot.create(:portal_offering, { :runnable => study_material,:clazz => clazz})
              default_portal_offering.runnable_type = assignable[:type]
              default_portal_offering.uuid = offering_uuid
              default_portal_offering.save!
            end
          end
        end
      end
    end

  end # end of create_assignments

  puts
  puts
  def self.record_learner_data
    # record investigation answers
    count = 0
    puts
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
        count += 1
        print '.'
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
        count += 1
        print '.'
      end
    end

    puts
    puts "Generated/updated #{count} student responses"
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

    return_value = {
                      :user => nil,
                      :created? => false,
                      :updated? => false,
                      :skipped? => false,
                      :conflicting_user => nil
                   }

    if user_by_uuid
      user = user_by_uuid
      user.password = user_info[:password]
      user.password_confirmation = user_info[:password]

      user.first_name = user_info[:first_name] if user_info[:first_name]
      user.last_name = user_info[:last_name] if user_info[:last_name]
      user.email = user_info[:email] if user_info[:email]

      user.save!

      return_value[:updated?] = true
      return_value[:user] = user

    elsif user_by_login.nil? && user_by_email.nil?

      user = FactoryBot.create(:user, user_info)

      user.save!
      user.confirm!

      return_value[:created?] = true
      return_value[:user] = user
    else
      conflicting_user = user_by_login || user_by_email

      return_value[:skipped?] = true
      return_value[:conflicting_user] = conflicting_user
    end

    if user
      roles.each do |role|
        user.add_role(role)
      end
    end

    return_value
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

      saveable_answer = Saveable::MultipleChoiceAnswer.where(uuid: data[:saveable_multiple_choice_answers_uuid]).first_or_create
      saveable_answer.multiple_choice = new_answer
      saveable_answer.save!

      saveable_mc_rationale_choice = Saveable::MultipleChoiceRationaleChoice.where(uuid: data[:saveable_multiple_choice_rationale_choices_uuid]).first_or_create
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

      blob = Dataservice::Blob.where(uuid: data[:dataservice_blob_uuid]).first_or_create
      blob.content = answer_text
      blob.token = answer_text
      blob.save!

      saveable_answer = Saveable::ImageQuestionAnswer.where(uuid: data[:saveable_image_question_answer_uuid]).first_or_create
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

  def self.create_default_materials_collections
    puts
    puts
    MaterialsCollection.destroy_all
    DEFAULT_DATA[:materials_collections].each do |key, mc|
      if (mc[:items_count] > 0)
        FactoryBot.create(:materials_collection_with_items, items_count: mc[:items_count], name: mc[:name], description: mc[:description])
      else
        FactoryBot.create(:materials_collection, name: mc[:name], description: mc[:description])
      end
    end
    puts "Generated Materials Collections"
  end

  def self.create_tag(scope, tag, interactive)
    if tag
      new_admin_tag = {:scope => scope.to_s, :tag => tag}
      if Admin::Tag.fetch_tag(new_admin_tag).size == 0
        admin_tag = Admin::Tag.new(new_admin_tag)
        admin_tag.save!
      end
      interactive.send("#{scope.to_s.chop}_list").add(tag)
      interactive.save!
    end
  end

  def self.create_default_interactives
    puts
    puts
    count = 0
    Interactive.destroy_all
    Admin::Tag.destroy_all
    DEFAULT_DATA[:interactives].each do |key, interactive|
      new_interactive = FactoryBot.create(:interactive, name: interactive[:name], description: interactive[:description], url: interactive[:url], image_url: interactive[:image_url], publication_status: interactive[:publication_status])
      user_login = interactive[:user]
      user = @default_users.find{|u| u.login == user_login}
      new_interactive.user_id = user.id
      create_tag(:model_types, interactive[:model_types], new_interactive) if interactive[:model_types]
      if interactive[:grade_levels]
        interactive[:grade_levels].split(', ').each do |gl|
          create_tag(:grade_levels, gl, new_interactive)
        end
      end
      if interactive[:subject_areas]
        interactive[:subject_areas].split(', ').each do |sa|
          create_tag(:subject_areas, sa, new_interactive)
        end
      end
      count += 1
    end
    puts "Generated #{count} Interactives"
  end
end # end of MockData
