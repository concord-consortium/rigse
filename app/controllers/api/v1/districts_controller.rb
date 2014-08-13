class API::V1::DistrictsController < API::APIController

	def index
		state = params['state']
		if state.blank?
			error("param 'state' is required for district list")
		else
			@districts = Portal::District.where('state' => state.upcase).select('name, id')
			render :json => @districts
		end
	end

end