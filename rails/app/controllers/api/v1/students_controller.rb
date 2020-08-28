class API::V1::StudentsController < API::APIController

  # POST api/v1/students
  def create
    registration = API::V1::StudentRegistration.new(params)

    # This was added to allow for registering after logging in the first time with SSO
    # But it also occurs if a user is able to access the registration form while being
    # logged in a different window.
    if current_user
      # If the user has a portal_teacher or portal_student, we don't want them re-registering
      # The errors in this case will be passed down to the registration form.
      # The use of class_word is so the error message is shown in the form.
      if current_user.portal_teacher
        return error(class_word: I18n.t('Registration.ErrorLoggedInAsTeacher'))
      elsif current_user.portal_student
        return error(class_word: I18n.t('Registration.ErrorLoggedInAsStudent'));
      else
        registration.set_user current_user
      end
    end

    if registration.valid?
      registration.save
      attributes = registration.attributes
      attributes.delete(:password)
      attributes.delete(:password_confirmation)

      #
      # For students, get rid of email address after registration
      #
      if session['omniauth_email']
        session['omniauth_email'] = nil
      end

      if session[:omniauth_origin]
        attributes["omniauth_origin"]   = session[:omniauth_origin]
        session[:omniauth_origin]       = nil
      end

      render :json => attributes
    else
      return error(registration.errors)
    end
  end

  # GET api/v1/students/check_class_word
  def check_class_word
    class_word = params.require(:class_word)
    found = Portal::Clazz.find_by_class_word(class_word)
    if found
      render :json => {'message' => 'ok'}
    else
      return error({'class_word' => 'class word not found'})
    end
  end

  # POST api/v1/students/:id/check_password
  # Why not GET like in check_class_word? We don't want to put password in URL params.
  def check_password
    student_id = params.require(:id)
    password   = params.require(:password)
    login      = Portal::Student.find(student_id).user.login
    return render :json => {'message' => 'ok'} if User.authenticate(login, password)
    return error({'password' => 'password incorrect'}, 401)
  end

  def join_class
    result = get_portal_clazz(params)
    return error(result[:error]) if result[:error]
    portal_clazz = result[:portal_clazz]

    if current_visitor.anonymous?
      return error("You must be logged in to sign up for a class!")
    end

    if current_visitor.portal_teacher
      return error("You can't signup for a class while logged in as a teacher!")
    end

    student = current_visitor.portal_student
    if !student
      grade_level = view_context.find_grade_level(params)
      student = Portal::Student.create(:user_id => current_visitor.id, :grade_level_id => grade_level.id)
    end
    student.process_class_word(params[:class_word])

    render_ok
  end

  # similar to #check_class_word but uses different error message to be consistent with #join_class
  def confirm_class_word
    result = get_portal_clazz(params)
    if result[:error]
      error(result[:error])
    else
      portal_clazz = result[:portal_clazz]
      render :json => { success: true, data: {teacher_name: portal_clazz.teacher.user.name} }, :status => :ok
    end
  end

  private

  def render_ok
    render :json => { success: true }, :status => :ok
  end

  def get_portal_clazz(params)
    class_word = params[:class_word]
    if !class_word
      return {error: "Missing class_word parameter"}
    end

    portal_clazz = Portal::Clazz.find_by_class_word(class_word)
    if !portal_clazz
      return {error: "The class word you provided, \"#{class_word}\", was not valid! Please check with your teacher to ensure you have the correct word."}
    end

    return {portal_clazz: portal_clazz}
  end

end
