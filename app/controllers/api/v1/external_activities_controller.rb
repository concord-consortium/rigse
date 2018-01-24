class API::V1::ExternalActivitiesController < API::APIController

  skip_before_filter :verify_authenticity_token

  def create
    authorize [:api, :v1, :external_activity]

    user, role = check_for_auth_token()
    return if !user

    name = params.require(:name)
    url = params.require(:url)

    begin
      validated_url = URI.parse(url)
    rescue Exception
      validated_url = nil
    end

    if !validated_url
      return error("Invalid url", 422)
    end

    external_report_id = 0
    if params[:external_report_url]
      external_report = ExternalReport.find_by_url(params[:external_report_url])
      if external_report
        external_report_id = external_report.id
      end
    end

    external_activity = ExternalActivity.create(
      :name               => name,
      :url                => url,
      :publication_status => params[:publication_status] || "private",
      :user               => user,
      :append_auth_token  => params[:append_auth_token] || false,
      :external_report_id => external_report_id
    )

    if !external_activity.valid?
      return error("Unable to create external activity", 422)
    end

    render status: 201, json: {edit_url: edit_external_activity_url(external_activity)}
  end

end
