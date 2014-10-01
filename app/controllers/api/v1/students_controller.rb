class API::V1::StudentsController < API::APIController

  # POST api/v1/students
	def create
		registration = API::V1::StudentRegistration.new(params)

		if registration.valid?
			registration.save
			render :json => registration.attributes
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
