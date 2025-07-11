class API::V1::ClassesController < API::APIController

  # GET api/v1/classes/:id
  def show
    clazz = Portal::Clazz.find_by_id(params[:id])
    if !clazz
      return error('The requested class was not found')
    end

    authorize clazz, :api_show?

    researcher_view = params[:researcher].present? && params[:researcher] != 'false'

    anonymize_students = researcher_view || !current_user.has_full_access_to_student_data?(clazz)

    render_info(clazz, anonymize_students)
  end

  def create
    authorize Portal::Clazz, :api_create?

    auto_generate_class_word = !!params[:auto_generate_class_word]

    return error("You must be a teacher to create a class") unless current_user.portal_teacher
    return error("Missing class name") unless params[:name].present?
    return error("Missing class word") unless auto_generate_class_word || params[:class_word].present?

    class_word = params[:class_word]
    if auto_generate_class_word
      class_word_prefix = params[:class_word_prefix] || "class"
      timestamp_offset = Time.now.to_i - Time.new(2025, 1, 1).to_i
      class_word = "#{class_word_prefix}_#{current_user.id}#{timestamp_offset}"
    end

    # create the class
    clazz = Portal::Clazz.create!(name: params[:name], class_word: class_word, teacher: current_user.portal_teacher)

    render :json => { id: clazz.id, class_word: class_word }, :status => :ok
  end

  # GET api/v1/classes/mine
  # lists the users classes
  def mine
    authorize Portal::Clazz, :mine?

    user_with_clazzes = current_user.portal_student || current_user.portal_teacher
    is_student = !!current_user.portal_student

    classes = user_with_clazzes.clazzes.map do |clazz|
      next get_info(clazz, false, is_student)
    end

    render :json => {
      classes: classes
    }
  end

  # GET api/v1/classes/info?class_word=[class word]
  def info
    class_word = params.require(:class_word)
    clazz = Portal::Clazz.find_by_class_word(class_word)
    if !clazz
      return error('The requested class was not found')
    end

    render_info(clazz, true)
  end

  def log_links
    clazz = Portal::Clazz.find_by_id(params[:id])
    if !clazz
      return error('The requested class was not found')
    end

    authorize clazz, :log_links?

    base_report_url = ENV["BASE_LOG_REPORT_URL"] || "https://log-puller.herokuapp.com"

    render :json => {
      offerings: clazz.offerings.includes(:runnable).map do |offering|

        portal_token = SignedJwt::create_portal_token(current_user, {
          offering_info_url: api_v1_offering_url(offering.id)
        })
        params = {portal_token: portal_token}.to_param

        next {
          name: offering.name,
          url: offering.runnable.respond_to?(:url) ? offering.runnable.url : nil,
          links: {
            download: "#{base_report_url}/download?#{params}",
            view: "#{base_report_url}/view?#{params}",
          }
        }
      end
    }
  end

  def set_is_archived
    clazz = Portal::Clazz.find_by_id(params[:id])

    authorize clazz, :set_is_archived?

    clazz.is_archived = ActiveModel::Type::Boolean.new.cast(params[:is_archived])
    clazz.save!

    render_ok
  end

  private

  def get_info(clazz, anonymize, exclude_students = false)
    state = nil
    if school = clazz.school
      state = school.state
    end

    students = if exclude_students
      []
    else
      clazz.students.includes(:user).map { |student|
        {
          :id => url_for(student.user),
          :user_id => student.user.id,
          :email => student.user.email,
          :first_name => anonymize ? student.anonymized_first_name : student.user.first_name,
          :last_name => anonymize ? student.anonymized_last_name : student.user.last_name
        }
      }
    end

    {
      :id => clazz.id,
      :uri => api_v1_class_url(clazz.id),
      :name => clazz.name,
      :state => state,
      :class_hash => clazz.class_hash,
      :class_word => clazz.class_word,
      :edit_path => edit_portal_clazz_path(clazz),
      :assign_materials_path => configured_search_path,
      :teachers => clazz.teachers.includes(:user).map { |teacher|
        {
          :id => url_for(teacher.user),
          :user_id => teacher.user.id,
          :first_name => teacher.user.first_name,
          :last_name => teacher.user.last_name
        }
      },
      :students => students,
      :offerings => clazz.teacher_visible_offerings.map { |offering|
        metadata = UserOfferingMetadata
          .where(offering_id: offering.id)
          .map { |m| { user_id: m.user_id, active: m.active, locked: m.locked } }

        {
          :id => offering.id,
          :name => offering.name,
          :active => offering.active,
          :locked => offering.locked,
          :metadata => metadata,
          :url => api_v1_offering_url(offering.id),
          :external_url => offering.runnable.respond_to?(:url) ? offering.runnable.url : nil,
        }
      },
      :external_class_reports => clazz.external_class_reports.map { |external_report|
        {
            :id => external_report.id,
            :name => external_report.name,
            :launch_text => external_report.launch_text,
            :url => portal_external_class_report_url(clazz, external_report)
        }
      },
    }
  end

  def render_info(clazz, anonymize)
    render :json => get_info(clazz, anonymize)
  end

  def render_ok
    render :json => { success: true }, :status => :ok
  end

end
