# This API is mostly used by Dashboard:
# https://github.com/concord-consortium/HASDashboard
# and some of the Portal Pages:
# https://github.com/concord-consortium/portal-pages
class API::V1::OfferingsController < API::APIController

  def show
    offering = Portal::Offering
                   .where(id: params[:id])
                   .includes(API::V1::Offering::INCLUDES_DEF)
                   .first
    unless offering
      return error('offering not found', 404)
    end

    authorize offering, :api_show?

    researcher_view = params[:researcher].present? && params[:researcher] != 'false'

    anonymize_students = researcher_view || !current_user.has_full_access_to_student_data?(offering.clazz)

    offering_api = API::V1::Offering.new(offering, request.protocol, request.host_with_port, current_user, params[:add_external_report], anonymize_students)
    render :json => offering_api.to_json, :callback => params[:callback]
  end

  # PUT /portal_offerings/1
  def update
    offering = Portal::Offering.find(params[:id])
    authorize offering
    offering.update!(portal_offering_strong_params(params))
    if params[:position]
      clazz = offering.clazz
      clazz.update_offering_position(offering, params[:position].to_i)
    end
    render :json => {message: 'OK'}, :callback => params[:callback]
  end

  def index
    authorize Portal::Offering, :api_index?
    # policy_scope will limit offerings to ones available to given user.
    # All the other filtering will filter this initial set of offerings.
    offerings = policy_scope(Portal::Offering).includes(API::V1::Offering::INCLUDES_DEF)

    # Process additional params to limit final offerings set.
    class_ids = []
    request_from_student = !!current_user.portal_student

    if params[:user_id] && !request_from_student
      user = User.find(params[:user_id])
      if !current_user.has_role?('admin') && current_user != user
        # Only admin can list offerings of other users / teachers.
        return error('access denied', 403)
      end
      if user.portal_teacher
        class_ids.concat(user.portal_teacher.clazz_ids)
      else
        # User is not a teacher, nothing to return.
        return render :json => [].to_json, :callback => params[:callback]
      end
    end

    if params[:class_id].present?
      clazz = Portal::Clazz.find(params[:class_id])
      if !current_user.has_role?('admin') && !clazz.is_teacher?(current_user)
        # Only admin can list offerings of somebody else's class.
        return error('access denied', 403)
      end
      class_ids.push(params[:class_id])
    end

    # Apply filtering.
    if class_ids.length > 0
      include_archived = params[:include_archived].present? || params[:class_id].present?
      filtered_class_ids = include_archived ? class_ids : Portal::Clazz.where({ id: class_ids, is_archived: false }).uniq
      offerings = offerings.where(clazz_id: filtered_class_ids)
    end

    filtered_offerings = offerings.reject { |o| o.archived? }
    filtered_offerings = filtered_offerings.map do |offering|
      API::V1::Offering.new(offering, request.protocol, request.host_with_port, current_user, params[:add_external_report])
    end

    # remove the other students in the list when a student requests their own offerings
    if request_from_student
      filtered_offerings.each do |offering|
        offering.students = offering.students.select { |s| s.user_id == current_user.id }
      end
    end

    render :json => filtered_offerings.to_json, :callback => params[:callback]
  end

  def find_tool(tool_id)
    return nil if tool_id.nil?
    tool = Tool.where(tool_id: tool_id).first
  end

  def create_for_external_activity
    authorize Portal::Offering, :api_create_for_external_activity?

    begin
      user, role = check_for_auth_token(params)
    rescue StandardError => e
      return error(e.message)
    end

    return error("A class_id is required") unless params[:class_id].present?
    return error("A name is required") unless params[:name].present?
    return error("An url is required") unless params[:url].present?
    return error("A rule is required") unless params[:rule].present?

    begin
      validated_url = URI.parse(params[:url])
    rescue Exception
      return error("Invalid url", 422)
    end

    # make sure the user is a teacher for the class
    clazz = Portal::Clazz.find(params[:class_id])
    if !user.has_role?('admin') && !clazz.is_teacher?(user)
      # Only admin can create offerings for somebody else's class.
      return error('You are not a teacher of the specified class', 403)
    end

    # make sure the offering does not already exist
    offering = Portal::Offering.where(clazz_id: clazz.id, runnable_type: 'ExternalActivity')
                .select { |o| o.runnable.url == params[:url] }
                .first
    if !offering

      # find the existing external activity
      external_activity = ExternalActivity.where(url: params[:url]).first
      if !external_activity
        # check if the rule allows the url
        rule = Admin::AutoExternalActivityRule.find_by(slug: params[:rule])
        return error("Unable to find #{params[:rule]} rule") unless rule
        return error("The URL is not allowed by the rule") unless rule.matches_pattern?(params[:url])

        # create a new external activity
        external_activity = ExternalActivity.create(
          :name                   => params[:name],
          :url                    => params[:url],
          :material_type          => "Activity",
          :publication_status     => params[:publication_status] || "published",
          :user_id                => rule.user_id,
          :append_auth_token      => params[:append_auth_token] || false,
          :author_url             => params[:author_url],
          :print_url              => params[:print_url],
          :tool                   => find_tool(params[:tool_id]),
          :thumbnail_url          => params[:thumbnail_url],
          :author_email           => params[:author_email],
          :is_locked              => params[:is_locked],
          :student_report_enabled => params[:student_report_enabled],
          :rubric_url             => params[:rubric_url],
          :rubric_doc_url         => params[:rubric_doc_url]
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
      end

      # create the offering
      offering = Portal::Offering.create!(
        clazz_id: clazz.id,
        runnable_type: external_activity.class.to_s,
        runnable_id: external_activity.id,
        active: true,
        locked: false,
      )
    end

    render :json => {id: offering.id}
  end

  def portal_offering_strong_params(params)
    params && params.permit(:active, :locked)
  end
end
