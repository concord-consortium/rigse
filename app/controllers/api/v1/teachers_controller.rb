class API::V1::TeachersController < API::APIController

  # Note that two scenarios are possible:
  # - 'school_id' is provided - school is expected to exist
  # - 'school_name' and 'district_id' are provided instead - school may be created in case of need
  def create
    authorize Api::V1::Teacher
    teacher_registration = API::V1::TeacherRegistration.new(params)
    if !current_visitor.anonymous?
      teacher_registration.set_user current_visitor
    end

    if teacher_registration.valid?
      teacher_registration.save
      render :json => teacher_registration.attributes
    else
      error(teacher_registration.errors)
    end
  end

  def email_available
    # no authorization needed ...
    found = User.find_by_email(params[:email])
    if !found
      render :json => {'message' => 'ok'}
    else
      error({'email' => 'address taken'})
    end
  end

  def login_available
    # no authorization needed ...
    found = User.find_by_login(params[:username])
    if !found
      render :json => {'message' => 'ok'}
    else
      error({'login' => 'username taken'})
    end
  end

end
