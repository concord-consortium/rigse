class API::V1::StatesController < API::APIController

  def index
    authorize Api::V1::State
    @states = Portal::StateOrProvince.configured
    # PUNDIT_REVIEW_SCOPE
    # PUNDIT_CHECK_SCOPE (found instance)
    # @states = policy_scope(Api::V1::State)
    render :json => @states
  end

end
