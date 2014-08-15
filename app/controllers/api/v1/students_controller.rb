class API::V1::StudentsController < API::APIController

	def create
		registration = API::V1::StudentRegistration.new(params)

		if registration.valid?
			render :json => registration.attributes
		else
			error(registration.errors)
		end
	end
end