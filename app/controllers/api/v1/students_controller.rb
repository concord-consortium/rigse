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
        error(class_word: I18n.t('Registration.ErrorLoggedInAsTeacher'))
        return
      elsif current_user.portal_student
        error(class_word: I18n.t('Registration.ErrorLoggedInAsStudent'));
        return
      else
        registration.set_user current_user
      end
    end

    if registration.valid?
      registration.save
      attributes = registration.attributes
      attributes.delete(:password)
      attributes.delete(:password_confirmation)
      render :json => attributes
    else
      error(registration.errors)
    end
  end

  # GET api/v1/students/check_class_word
  def check_class_word
    class_word = params.require(:class_word)
    found = Portal::Clazz.find_by_class_word(class_word)
    if found
      render :json => {'message' => 'ok'}
    else
      error({'class_word' => 'class word not found'})
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

end
