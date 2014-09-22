class API::V1::StudentsController < API::APIController

	def create
		registration = API::V1::StudentRegistration.new(params)

		if registration.valid?
			registration.save
			render :json => registration.attributes
		else
			error(registration.errors)
		end
	end

  def check_class_word
    found = Portal::Clazz.find_by_class_word(params[:class_word])
    if found
      render :json => {'message' => 'ok' }
    else
      error({'login' => 'username taken'})
    end
  end

end