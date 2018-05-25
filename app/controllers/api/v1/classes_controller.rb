class API::V1::ClassesController < API::APIController

  # GET api/v1/classes/:id
  def show
    user, role = check_for_auth_token()
    return if !user

    if user.anonymous?
      return error('You must be logged in to use this endpoint')
    end

    if !user.portal_student && !user.portal_teacher
      return error('You must be logged in as a student or teacher to use this endpoint')
    end

    clazz = Portal::Clazz.find_by_id(params[:id])
    if !clazz
      return error('The requested class was not found')
    end

    student_in_class = user.portal_student && user.portal_student.has_clazz?(clazz)
    teacher_in_class = !student_in_class || (user.portal_teacher && user.portal_teacher.has_clazz?(clazz))

    if (!student_in_class && !teacher_in_class)
      return error('You are not a student or teacher of the requested class')
    end

    render_info clazz
  end

  # GET api/v1/classes/mine
  # lists the users classes
  def mine
    user, role = check_for_auth_token()
    return if !user

    if user.anonymous?
      return error('You must be logged in to use this endpoint')
    end

    user_with_clazzes = user.portal_student || user.portal_teacher
    if !user_with_clazzes
      return error('You must be logged in as a student or teacher to use this endpoint')
    end

    render :json => {
      classes: user_with_clazzes.clazzes.map do |clazz|
        next {
          :uri => api_v1_class_url(clazz.id),
          :name => clazz.name,
          :class_hash => clazz.class_hash
        }
      end
    }
  end

  # GET api/v1/classes/info?class_word=[class word]
  def info
    class_word = params.require(:class_word)
    clazz = Portal::Clazz.find_by_class_word(class_word)
    if !clazz
      return error('The requested class was not found')
    end

    render_info clazz
  end

  def log_links
    # allow only admins for now
    return error('You must be an admin to use this endpoint') unless current_user && current_user.has_role?("admin")

    clazz = Portal::Clazz.find_by_id(params[:id])
    if !clazz
      return error('The requested class was not found')
    end

    base_report_url = ENV["BASE_LOG_REPORT_URL"] || "https://log-puller.herokuapp.com"

    render :json => {
      offerings: clazz.offerings.includes(:runnable).map do |offering|

        portal_token = SignedJWT::create_portal_token(current_user, {
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

  private

  def render_info(clazz)
    state = nil
    if school = clazz.school
      state = school.state
    end

    render :json => {
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
          :first_name => teacher.user.first_name,
          :last_name => teacher.user.last_name
        }
      },
      :students => clazz.students.includes(:user).map { |student|
        {
          :id => url_for(student.user),
          :email => student.user.email,
          :first_name => student.user.first_name,
          :last_name => student.user.last_name
        }
      },
      :offerings => clazz.offerings.map { |offering|
        {
          :id => offering.id,
          :name => offering.name,
          :active => offering.active,
          :locked => offering.locked,
          :url => api_v1_offering_url(offering.id)
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

end
