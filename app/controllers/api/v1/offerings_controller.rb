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
    @offering = Portal::Offering.find(params[:id], include: {
        learners: {student: :user},
        clazz: {students: :user}
    })
    authorize @offering, :api_show?
    @offering_api = API::V1::Offering.new(@offering, request.protocol, request.host_with_port)
    render :json => @offering_api.to_json, :callback => params[:callback]
  end
end
