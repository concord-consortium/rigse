class API::V1::ExternalActivitiesController < API::APIController

  skip_before_filter :verify_authenticity_token

  def create
    authorize [:api, :v1, :external_activity]

    begin
      user, _ = check_for_auth_token(params)
    rescue StandardError => e
      raise Pundit::NotAuthorizedError, e.message
    end

    name = params.require(:name)
    url = params.require(:url)

    validated_url = begin
      URI.parse(url)
    rescue StandardError
      nil
    end

    unless validated_url
      raise Pundit::NotAuthorizedError, "Invalid url"
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

    unless external_activity.valid?
      raise Pundit::NotAuthorizedError, "Unable to create external activity"
    end

    render status: 201, json: {edit_url: edit_external_activity_url(external_activity)}
  end

end
