class API::V1::OfferingsController < API::APIController

  private
  def pundit_user_not_authorized(exception)
    render status: 403, json: {
        success: false,
        message: 'Not authorized'
    }
  end

  public
  def show
    authorize [:api, :v1, :offering]
    @offering = API::V1::Offering.new(params[:id], request.protocol, request.host_with_port)
    render :json => @offering.to_json, :callback => params[:callback]
  end
end
