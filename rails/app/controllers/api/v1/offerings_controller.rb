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
    offering_api = API::V1::Offering.new(offering, request.protocol, request.host_with_port, current_user, params[:add_external_report])
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

    if params[:user_id]
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
    render :json => filtered_offerings.to_json, :callback => params[:callback]
  end

  # DEPRECIATED
  # This route is still used directly by https://github.com/concord-consortium/sharinator
  def for_class
    offering =  Portal::Offering.find(params[:id])
    params[:class_id] = offering.clazz.id
    index
  end

  # DEPRECIATED
  def for_teacher
    offering =  Portal::Offering.find(params[:id])
    params[:user_id] = offering.clazz.teacher.user.id
    index
  end

  def portal_offering_strong_params(params)
    params && params.permit(:active, :locked)
  end
end
