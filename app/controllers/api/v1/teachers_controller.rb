class API::V1::TeachersController < API::APIController

  # Note that two scenarios are possible:
  # - 'school_id' is provided - school is expected to exist
  # - 'school_name', 'country_id' and 'zipcode' are provided instead - school may be created in case of need
  def create
    teacher_registration = API::V1::TeacherRegistration.new(params)
    if !current_visitor.anonymous?
      teacher_registration.set_user current_visitor
    end

    if should_create_new_school(teacher_registration)
      school_id, school_reg_errors = create_new_school
      if school_id
        teacher_registration.school_id = school_id
      else
        error(school_reg_errors)
        return
      end
    end

    if teacher_registration.valid?
      teacher_registration.save
      render status: 201, json: teacher_registration.attributes
    else
      error(teacher_registration.errors)
    end
  end

  def email_available
    found = User.find_by_email(params[:email])
    if !found
      render :json => {'message' => 'ok'}
    else
      error({'email' => 'address taken'})
    end
  end

  def login_available
    found = User.find_by_login(params[:username])
    if !found
      render :json => {'message' => 'ok'}
    else
      error({'login' => 'username taken'})
    end
  end

  #
  # Check if login is both a valid login name and
  # if the login is available.
  #
  def login_valid
    puts "***\nChecking login #{params[:username]}\n***\n"
    valid = User.login_regex.match(params[:username])
    if valid
      puts "***\nChecking login available #{params[:username]}\n***\n"
      login_available 
    else
      error({'login' => 'username not valid'})
    end
  end

  #
  # Determine if a user's given name or surname is valid based on
  # what pattern is defined in the User class.
  #
  def name_valid
    name = params[:name]

    puts "***\nValidating #{name}\n***"

    valid = User.name_regex.match(name)
    if valid
      render :json => {'message' => 'ok'}
    else
      error({'name' => 'name not valid'})
    end
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
