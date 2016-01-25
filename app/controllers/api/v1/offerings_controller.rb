class API::V1::OfferingsController < API::APIController

  def show
    # TODO: authorize!
    offering = API::V1::Offering.new(params[:id], request.protocol, request.host_with_port)
    render :json => offering.to_json, :callback => params[:callback]
  end
end
