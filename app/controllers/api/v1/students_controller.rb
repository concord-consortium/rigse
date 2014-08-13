class API::V1::StudentsController < API::APIController

	def create
		errors     = {}
		student    = {}
		attributes = ['first_name', 'last_name', 'class_word', 'password', 'questions', 'answers','over_18']
		
		attributes.each do |field|
			if params[field].blank?
				errors[field] = "required field"
			else
				student[field] = params[field]
			end
		end
		
		if errors.size > 0
			error(errors)
		else
			# TODO: actually do the model creation.
			# this is just a BOGUS response to expedite client testing
			student['username']  = 'bogus_username'
			student['id']        = '007'
			render :json => student
		end
	end
end