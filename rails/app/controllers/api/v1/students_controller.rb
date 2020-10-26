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
    result = get_portal_clazz_by_word(params)
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
      student = Portal::Student.create(:user_id => current_visitor.id, :grade_level_id => grade_level.id) # strong params not required
    end
    student.process_class_word(params[:class_word])

    render_ok
  end

  # similar to #check_class_word but uses different error message to be consistent with #join_class
  def confirm_class_word
    result = get_portal_clazz_by_word(params)
    if result[:error]
      error(result[:error])
    else
      portal_clazz = result[:portal_clazz]
      render :json => { success: true, data: {teacher_name: portal_clazz.teacher.user.name} }, :status => :ok
    end
  end

  def register
    result = get_portal_clazz_by_id(params)
    return error(result[:error]) if result[:error]
    portal_clazz = result[:portal_clazz]

    user_attributes = params[:user]
    if !user_attributes
      return error("Missing user parameters")
    end

    if user_attributes[:first_name].nil?
      return error("Missing user first_name parameter")
    end
    if user_attributes[:last_name].nil?
      return error("Missing user last_name parameter")
    end

    portal_clazz = result[:portal_clazz]
    if !portal_clazz.is_teacher?(current_user)
      return error("You must be a teacher of the class to register and add students")
    end

    grade_level = view_context.find_grade_level(params)

    user_attributes[:login] = Portal::Student.generate_user_login(user_attributes[:first_name], user_attributes[:last_name])
    user_attributes[:email] = Portal::Student.generate_user_email

    user = User.new(user_strong_params(user_attributes))
    if !user.valid?
      return error(user.errors.full_messages.uniq.join(". ").gsub("..", "."))
    end

    # temporarily disable sending email notifications for state change events
    user.skip_notifications = true
    if !user.save
      return error("Unable to save newly created user")
    end
    user.confirm!

    if current_settings.allow_default_class || grade_level.nil?
      portal_student = Portal::Student.create(:user_id => user.id) # strong params not required
    else
      portal_student = Portal::Student.create(:user_id => user.id, :grade_level_id => grade_level.id) # strong params not required
    end

    if !portal_student
      return error("Unable to create student")
    end

    if !portal_student.student_clazzes.create(:clazz_id => portal_clazz.id, :student_id => portal_student.id, :start_time => Time.now)
      return error("Unable to add student to class")
    end

    render :json => {
      success: true,
      data: {
        user: {
          id: user.id,
          login: user.login,
          email: user.email
        },
        student: {
          id: portal_student.id
        },
        clazz: {
          id: portal_clazz.id
        }
      }
    }, :status => :ok
  end

  def add_to_class
    result = get_portal_clazz_by_id(params)
    return error(result[:error]) if result[:error]
    portal_clazz = result[:portal_clazz]

    student_id = params[:student_id]
    if !student_id
      return error("Missing student_id parameter")
    end

    student = Portal::Student.find_by_id(student_id)
    if !student
      return error("Invalid student_id: #{student_id}")
    end

    if !portal_clazz.is_teacher?(current_user)
      return error("You must be a teacher of the class to add students")
    end

    student.add_clazz(portal_clazz)

    render_ok
  end

  def remove_from_class
    student_clazz_id = params[:student_clazz_id]
    if !student_clazz_id
      return error("Missing student_clazz_id parameter")
    end

    student_clazz = Portal::StudentClazz.find_by_id(student_clazz_id)
    if !student_clazz
      return error("Invalid student_clazz_id: #{student_clazz_id}")
    end

    portal_clazz = student_clazz.clazz
    if !portal_clazz.is_teacher?(current_user)
      return error("You must be a teacher of the class to remove students")
    end

    student_clazz.destroy

    render_ok
  end

  private

  def render_ok
    render :json => { success: true }, :status => :ok
  end

  def get_portal_clazz_by_word(params)
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

  def get_portal_clazz_by_id(params)
    clazz_id = params[:clazz_id]
    if !clazz_id
      return {error: "Missing clazz_id parameter"}
    end

    portal_clazz = Portal::Clazz.find_by_id(clazz_id)
    if !portal_clazz
      return {error: "Invalid clazz_id: #{clazz_id}"}
    end

    return {portal_clazz: portal_clazz}
  end

  def teacher_of_class?(clazz)
    true
  end

  def portal_student_strong_params(params)
    params.permit(:grade_level_id, :user_id, :uuid)
  end

  # STRONG_PARAMS_REVIEW: model attr_accessible didn't match model attributes:
  #  attr_accessible: :can_add_teachers_to_cohorts, :confirmation_token, :confirmed_at, :email, :email_subscribed, :external_id, :first_name, :have_consent, :last_name, :login, :of_consenting_age, :password, :password_confirmation, :remember_me, :require_password_reset, :sign_up_path, :state
  #  model attrs:     :asked_age, :can_add_teachers_to_cohorts, :confirmation_sent_at, :confirmation_token, :confirmed_at, :current_sign_in_at, :current_sign_in_ip, :default_user, :deleted_at, :email, :email_subscribed, :encrypted_password, :external_id, :first_name, :have_consent, :last_name, :last_sign_in_at, :last_sign_in_ip, :login, :of_consenting_age, :password_salt, :remember_created_at, :remember_token, :require_password_reset, :require_portal_user_type, :reset_password_token, :sign_in_count, :sign_up_path, :site_admin, :state, :unconfirmed_email, :uuid
  def user_strong_params(params)
    params.permit(:asked_age, :can_add_teachers_to_cohorts, :confirmation_sent_at, :confirmation_token, :confirmed_at,
                  :current_sign_in_at, :current_sign_in_ip, :default_user, :deleted_at, :email, :email_subscribed,
                  :encrypted_password, :external_id, :first_name, :have_consent, :last_name, :last_sign_in_at, :last_sign_in_ip,
                  :login, :of_consenting_age, :password_salt, :remember_created_at, :remember_token, :require_password_reset,
                  :require_portal_user_type, :reset_password_token, :sign_in_count, :sign_up_path, :site_admin, :state,
                  :unconfirmed_email, :uuid)
  end
end
