class API::V1::ReportsController < API::APIController
  rescue_from Pundit::NotAuthorizedError, with: :pundit_user_not_authorized

  def pundit_user_not_authorized(exception)
    unauthorized
  end

  # GET api/v1/reports/:id
  def show
    offering = Portal::Offering.find(params[:id])
    student_ids = params["student_ids"]
    activity_id = params["activity_id"]
    is_student_report =
        student_ids &&
        student_ids.length > 0 &&
        current_visitor.portal_student &&
        student_ids.first.to_s == current_visitor.portal_student.id.to_s

    report = API::V1::Report.new({
         offering: offering,
         protocol: request.protocol,
         host_with_port: request.host_with_port,
         student_ids: student_ids,
         activity_id: activity_id,
         hide_controls: is_student_report
    })
    authorize report
    render json: report.to_json
  end

  # PUT api/v1/reports/:id
  def update
    offering = Portal::Offering.find(params[:id])
    authorize offering, :api_report?
    if params[:visibility_filter]
      update_visibility_filter(offering.report_embeddable_filter, params[:visibility_filter])
    end
    offering.update_attributes!(report_params)
    head :ok
  end

  private

  def update_visibility_filter(filter, filter_params)
    # In some cases client can send only one parameter, so make sure that the second one won't be affected.
    # Note that we should accept an empty array, so #present? or #blank? can't be used here.
    filter.embeddable_keys = filter_params[:questions] unless filter_params[:questions].nil?
    filter.ignore = !filter_params[:active]            unless filter_params[:active].nil?
    filter.save!
  end

  def report_params
    params.permit(:anonymous_report)
  end
end
