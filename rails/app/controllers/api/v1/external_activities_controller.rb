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

    external_activity = ExternalActivity.create( # strong params not required
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

  def external_activity_strong_params(params)
    params.permit(:allow_collaboration, :append_auth_token, :append_learner_id_to_url, :append_survey_monkey_uid,
                  :archive_date, :archived_description, :author_email, :author_url, :credits, :enable_sharing,
                  :has_pretest, :has_teacher_edition, :is_archived, :is_assessment_item, :is_featured, :is_locked,
                  :is_official, :keywords, :launch_url, :license_code, :logging, :long_description,
                  :long_description_for_teacher, :material_type, :name, :offerings_count, :popup, :print_url,
                  :publication_status, :rubric_url, :save_path, :saves_student_data, :short_description,
                  :student_report_enabled, :teacher_guide_url, :teacher_resources_url, :template_id, :template_type,
                  :thumbnail_url, :tool_id, :url, :user_id, :uuid)
  end
end
