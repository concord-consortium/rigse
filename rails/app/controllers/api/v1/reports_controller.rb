class API::V1::ReportsController < API::APIController

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
    if params[:feedback_opts]
      API::V1::Report.update_feedback_settings(offering, params[:feedback_opts])
    end
    if params[:actvity_feedback_opts] # actvity -> this typo can't be fixed to keep API backward-compatible
      API::V1::Report.update_activity_feedback_settings(activity_feedback_settings_update_strong_params(params[:actvity_feedback_opts])) # actvity -> this typo can't be fixed to keep API backward-compatible
    end
    if params[:feedback]
      API::V1::Report.submit_feedback(params[:feedback])
    end
    if params[:activity_feedback]
      API::V1::Report.submit_activity_feedback(activity_feedback_update_strong_params(params[:activity_feedback]))
    end

    # These actions have been added to support new Firestore-based Portal Report. Data format is a bit different
    # than it used to be. New Portal Report still has to post activity feedback settings and content, so it can be
    # displayed in the progress table. Note that progress table only shows activity-level feedback, so question
    # feedback can be ignored. Once progress table is redone, this code can be removed.
    if params[:activity_feedback_opts_v2]
      # Activity feedback coming from new, firestore-based Portal Report.
      API::V1::Report.update_activity_feedback_settings_v2(offering, activity_feedback_settings_update_v2_strong_params(params[:activity_feedback_opts_v2]))
    end
    if params[:activity_feedback_v2]
      # Activity feedback coming from new, firestore-based Portal Report.
      API::V1::Report.submit_activity_feedback_v2(offering, activity_feedback_v2_update_strong_params(params[:activity_feedback_v2]))
    end
    if params[:rubric_v2]
      # Rubric coming from new, firestore-based Portal Report.
      API::V1::Report.update_rubric_v2(offering, params[:rubric_v2])
    end

    if params[:anonymous_report]
      offering.update_attributes!(params[:anonymous_report])
    end
    head :ok
  end

  private

  def update_visibility_filter(filter, filter_params)
    # In some cases client can send only one parameter, so make sure that the second one won't be affected.
    # Note that we should accept an empty array, so #present? or #blank? can't be used here.
    # also see: http://stackoverflow.com/questions/14647731/rails-converts-empty-arrays-into-nils-in-params-of-the-request

    if filter_params.has_key?('questions')
      questions = filter_params[:questions] || []
      filter.embeddable_keys = questions
    end
    if !filter_params[:active].nil?
      active = ActiveModel::Type::Boolean.new.cast(filter_params[:active])
      filter.ignore = !active
    end
    filter.save!
  end

  def activity_feedback_update_strong_params(params)
    # NOTE: learner_id is permitted here even though it is portal_learner_id in the schema as the parameter name used by the caller is learner_id
    rubric_feedback_strong_params(params, [:text_feedback, :score, :has_been_reviewed, :activity_feedback_id, :learner_id])
  end

  def activity_feedback_v2_update_strong_params(params)
    # NOTE: student_user_id and activity_index is permitted here as it is sent to the controller but not used directly in the model
    #       (it is used to look up other related models)
    rubric_feedback_strong_params(params, [:text_feedback, :score, :has_been_reviewed, :activity_feedback_id, :student_user_id, :activity_index])
  end

  def activity_feedback_settings_update_strong_params(params)
    # NOTE: activity_feedback_id is permitted as it is used as a controller parameter but is not in the model
    params && params.permit(:enable_text_feedback, :max_score, :score_type, :activity_id, :portal_offering_id, :use_rubric, :rubric, :activity_feedback_id)
  end

  def activity_feedback_settings_update_v2_strong_params(params)
    # NOTE: activity_index is permitted as it is used as a controller parameter but is not in the model
    params && params.permit(:enable_text_feedback, :max_score, :score_type, :activity_id, :portal_offering_id, :use_rubric, :rubric, :activity_index)
  end

  def rubric_feedback_strong_params(params, permitted)
    if params
      # allow for an arbitrary shaped object in rubric_feedback
      has_rubric_feedback = params.has_key?("rubric_feedback")
      if has_rubric_feedback
        permitted_rubric_feedback = ActionController::Parameters.new(params[:rubric_feedback].to_unsafe_hash)
        permitted_rubric_feedback.permit!
      end

      params = params.permit(*permitted)

      if has_rubric_feedback
        params[:rubric_feedback] = permitted_rubric_feedback
      end
    end
    params
  end

end
