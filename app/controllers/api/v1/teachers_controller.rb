class API::V1::TeachersController < API::APIController

	def create
		errors     = {}
		teacher    = {}
		attributes = ['first_name', 'last_name', 'email', 'school_id', 'login', 'password']
		
		attributes.each do |field|
			if params[field].blank?
				errors[field] = "required field"
			else
				teacher[field] = params[field]
			end
		end
		
		if errors.size > 0
			error(errors)
		else
			# TODO: actually do the model creation.
			# this is just a BOGUS response to expedite client testing
			teacher['id'] = '007'
			render :json => teacher
		end
	end

end