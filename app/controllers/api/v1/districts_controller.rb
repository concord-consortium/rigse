class API::V1::DistrictsController < API::APIController

  def index
    authorize Api::V1::District
    state = params['state']
    if state.blank?
      error("param 'state' is required for district list")
    else
      @districts = Portal::District.where('state' => state.upcase).select('name, id')
      # PUNDIT_REVIEW_SCOPE
      # PUNDIT_CHECK_SCOPE (found instance)
      # @districts = policy_scope(Api::V1::District)
      render :json => @districts
    end
  end

end
