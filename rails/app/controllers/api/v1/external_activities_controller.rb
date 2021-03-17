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
      :name                   => name,
      :url                    => url,
      :publication_status     => params[:publication_status] || "private",
      :user                   => user,
      :append_auth_token      => params[:append_auth_token] || false,
      :author_url             => params[:author_url],
      :print_url              => params[:print_url],
      :tool                   => ActivityRuntimeAPI.find_tool(params[:tool_id]),
      :thumbnail_url          => params[:thumbnail_url],
      :author_email           => params[:author_email],
      :is_locked              => params[:is_locked],
      :student_report_enabled => params[:student_report_enabled]
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

  def update_by_url
    begin
      user, role = check_for_auth_token(params)
    rescue StandardError => e
      return error(e.message, 403)
    end

    external_activity = ExternalActivity.where(url: params[:url]).first
    authorize external_activity

    permitted_params = params.permit(:name, :student_report_enabled, :thumbnail_url, :is_locked, :append_auth_token, :save_path, :publication_status)

    if external_activity.update(permitted_params)
      render :json => { success: true }, :status => :ok
    else
      error("Unable to save external activity options")
    end
  end


  def update_basic
    begin
      user, role = check_for_auth_token(params)
    rescue StandardError => e
      return error(e.message, 403)
    end

    external_activity = ExternalActivity.find(params[:id])
    authorize external_activity

    external_activity.publication_status = params[:publication_status]
    external_activity.grade_level_list = (params[:grade_levels] || [])
    external_activity.subject_area_list = (params[:subject_areas] || [])
    external_activity.sensor_list = (params[:sensors] || [])

    if external_activity.save
      render :json => { success: true }, :status => :ok
    else
      error("Unable to save external activity options")
    end
  end
end
