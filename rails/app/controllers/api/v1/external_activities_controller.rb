class API::V1::ExternalActivitiesController < API::APIController

  skip_before_filter :verify_authenticity_token

  def create
    authorize [:api, :v1, :external_activity]

    begin
      user, role = check_for_auth_token(params)
    rescue StandardError => e
      return error(e.message)
    end

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

    external_activity = ExternalActivity.create(
      :name               => name,
      :url                => url,
      :publication_status => params[:publication_status] || "private",
      :user               => user,
      :append_auth_token  => params[:append_auth_token] || false
    )

    if params[:external_report_url]
      external_report = ExternalReport.find_by_url(params[:external_report_url])
      if external_report
        external_activity.external_reports=[external_report]
        external_activity.save
      end
    end

    if !external_activity.valid?
      return error("Unable to create external activity", 422)
    end

    render status: 201, json: {edit_url: edit_external_activity_url(external_activity)}
  end

end
