class API::V1::TeachersController < API::APIController

  # Note that two scenarios are possible:
  # - 'school_id' is provided - school is expected to exist
  # - 'school_name', 'country_id' and 'zipcode' are provided instead - school may be created in case of need
  def create
    teacher_registration = API::V1::TeacherRegistration.new(params)

    # This was added to allow for registering after logging in the first time with SSO
    # But it also occurs if a user is able to access the registration form while being
    # logged in a different window.
    if current_user
      # If the user has a portal_teacher or portal_student, we don't want them re-registering
      # The errors in this case will be passed down to the registration form.
      # The use of school_id is so the error message is shown in the form.
      if current_user.portal_teacher
        return error(school_id: I18n.t('Registration.ErrorLoggedInAsTeacher'))
      elsif current_user.portal_student
        return error(school_id: I18n.t('Registration.ErrorLoggedInAsStudent'))
      else
        teacher_registration.set_user current_user
      end
    end

    if should_create_new_school(teacher_registration)
      school_id, school_reg_errors = create_new_school
      if school_id
        teacher_registration.school_id = school_id
      else
        return error(school_reg_errors)
      end
    end

    if teacher_registration.valid?
      teacher_registration.save
      attributes = teacher_registration.attributes
      attributes.delete(:password)
      attributes.delete(:password_confirmation)

      #
      # For teachers, if we came from omniauth set the valid email address.
      #
      if session[:omniauth_email]
        current_user.email = session['omniauth_email']
        current_user.save!
        session['omniauth_email'] = nil
        finish_enews_subscription
      end

      if session[:omniauth_origin]
        attributes["omniauth_origin"]   = session[:omniauth_origin]
        session[:omniauth_origin]       = nil
      end

      render status: 201, json: attributes
    else
      return error(teacher_registration.errors)
    end
  end

  def email_available
    found = User.find_by_email(params[:email])
    if !found
      render :json => {'message' => 'ok'}
    else
      return error({'email' => 'address taken'})
    end
  end

  def login_available
    found = User.find_by_login(params[:username])
    if !found
      render :json => {'message' => 'ok'}
    else
      return error({'login' => 'username taken'})
    end
  end

  #
  # Check if login is both a valid login name and
  # if the login is available.
  #
  def login_valid
    valid = User.login_regex.match(params[:username])
    if valid
      login_available
    else
      return error({'login' => 'username not valid'})
    end
  end

  #
  # Determine if a user's given name or surname is valid based on
  # what pattern is defined in the User class.
  #
  def name_valid
    name = params[:name]

    valid = User.name_regex.match(name)
    if valid
      render :json => {'message' => 'ok'}
    else
      return error({'name' => 'name not valid'})
    end
  end

  def get_enews_subscription
    teacher_id = params.require(:id)
    if current_user.nil?
      return error(I18n.t('Registration.ErrorNotAllowed'))
    end

    if current_user.portal_teacher
      current_teacher_id = current_user.portal_teacher.id
    else
      current_teacher_id = ''
    end

    if teacher_id != current_teacher_id.to_s && !current_user.has_role?('admin')
      return error(I18n.t('Registration.ErrorNotAllowed'))
    end

    email = current_user.portal_teacher.email
    enews_response_data = EnewsSubscription::get_status(email)
    enews_status = enews_response_data['status']

    if enews_status == 'subscribed'
      subscribed = true
    else
      subscribed = false
    end

    return render :json => {'subscribed' => "#{subscribed}"}
  end

  def update_enews_subscription
    teacher_id = params.require(:id)
    teacher_account = Portal::Teacher.find(teacher_id)

    if current_user.nil?
      return error(I18n.t('Registration.ErrorNotAllowed'))
    end

    if current_user.portal_teacher
      current_teacher_id = current_user.portal_teacher.id
    else
      current_teacher_id = ''
    end

    if teacher_id != current_teacher_id.to_s && !current_user.has_role?('admin')
      return error(I18n.t('Registration.ErrorNotAllowed'))
    end

    email = teacher_account.email
    first_name = teacher_account.first_name
    last_name = teacher_account.last_name
    status = params.require(:status)
    enews_response_data = EnewsSubscription::set_status(email, status, first_name, last_name)
    enews_status = enews_response_data['status']

    return render :json => {'subscribed' => "#{enews_status}"}

  end

  private

  def school_params_provided?
    params[:school_name].present? && params[:country_id].present? && params[:zipcode].present?
  end

  def should_create_new_school(teacher_registration)
    # We should create a new school only if there are appropriate params provided and teacher params are valid
    # (only school_id can be missing).
    school_params_provided? && teacher_registration.valid_except_from_school_id
  end

  def create_new_school
    # School name, zipcode and country are provided. Look for school that matches these criteria.
    # If school is not found, try to create a new one.
    school = API::V1::SchoolRegistration.find(params)
    return [school.id, nil] if school
    school = API::V1::SchoolRegistration.new(params)
    if school.valid?
      school.save
      [school.school_id, nil]
    else
      [nil, school.errors]
    end
  end
end
