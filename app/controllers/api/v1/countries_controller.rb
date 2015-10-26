class API::V1::CountriesController < API::APIController

	def index
	  # PUNDIT_REVIEW_AUTHORIZE
	  # PUNDIT_CHECK_AUTHORIZE
	  authorize Api::V1::Country
		@countries = Portal::Country.all.map{ |c| {name: c.name, id: c.id} }
	  # PUNDIT_REVIEW_SCOPE
	  # PUNDIT_CHECK_SCOPE (found instance)
	  @countries = policy_scope(Api::V1::Country)
		render :json => @countries
	end

end
