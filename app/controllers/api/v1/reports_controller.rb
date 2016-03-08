class API::V1::ReportsController < API::APIController
  rescue_from Pundit::NotAuthorizedError, with: :pundit_user_not_authorized

  def pundit_user_not_authorized(exception)
    unauthorized
  end

  # GET api/v1/reports/:id
  def show
    offering = Portal::Offering.find(params[:id])
    # authorize offering, :api_report?
    render json: API::V1::Report.new(offering, request.protocol, request.host_with_port).to_json
  end

  # POST api/v1/reports/:id
  def update
    offering = Portal::Offering.find(params[:id])
    # authorize offering, :api_report?
    puts params
    if params[:visibility_filter]
      update_visibility_filter(offering.report_embeddable_filter, params[:visibility_filter])
    end
    offering.update_attributes!(report_params)
    head :ok
  end

  private

  def update_visibility_filter(filter, filter_params)
    filter.embeddable_keys = filter_params[:questions] unless filter_params[:questions].nil?
    filter.ignore = !filter_params[:active]            unless filter_params[:active].nil?
    filter.save!
  end

  def report_params
    params.permit(:anonymous_report)
  end
end
