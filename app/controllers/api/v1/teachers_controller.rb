class API::V1::TeachersController < API::APIController

	def create
		registration = API::V1::TeacherRegistration.new(params)

		if registration.valid?
			registration.save
			render :json => registration.attributes
		else
			error(registration.errors)
		end
	end

end