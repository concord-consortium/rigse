class API::V1::StatesController < API::APIController

	def index
		@states = Portal::StateOrProvince.configured
		render :json => @states
	end

end