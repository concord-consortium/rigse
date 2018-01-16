class API::V1::ExternalActivitiesController < API::APIController

  skip_before_filter :verify_authenticity_token

  def create_collabspace_activity
    user, role = check_for_auth_token()
    return if !user

    name = params[:name]
    url = params[:url]

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
      :publication_status => "published",
      :user               => user,
      :append_auth_token  => true,
      :external_report_id => ENV["COLLABSPACE_REPORT_ID"]
    )

    if !external_activity.valid?
      return error("Unable to create external activity", 422)
    end

    render status: 201, json: {edit_url: edit_external_activity_url(external_activity)}
  end

end
