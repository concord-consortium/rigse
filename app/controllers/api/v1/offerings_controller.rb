# This API is mostly used by Dashboard:
# https://github.com/concord-consortium/HASDashboard
# and some of the Portal Pages:
# https://github.com/concord-consortium/portal-pages
class API::V1::OfferingsController < API::APIController

  # Optimize SQL queries based on API::V1::Offering structure.
  INCLUDES_DEF = {
      runnable: [:template, :external_report],
      learners: [:report_learner, {learner_activities: :activity, student: :user}],
      clazz: {students: :user}
  }

  def show
    offering = Portal::Offering
                   .where(id: params[:id])
                   .includes(INCLUDES_DEF)
                   .first
    unless offering
      return error('offering not found', 404)
    end
    authorize offering, :api_show?
    offering_api = API::V1::Offering.new(offering, request.protocol, request.host_with_port)
    render :json => offering_api.to_json, :callback => params[:callback]
  end

  def own
    authorize Portal::Offering, :api_own?
    # if ?class_id param is present, offerings will be limited just to one class.
    clazz_ids = current_user.portal_teacher.clazz_ids
    if params[:class_id].present?
      # Intersection of own classes and provided class_id. We don't want to let user check offerings of class which
      # is not owned by him.
      clazz_ids = clazz_ids & [params[:class_id].to_i]
    end
    offerings = Portal::Offering
                    .where(clazz_id: clazz_ids)
                    .includes(INCLUDES_DEF)
    offering_api = offerings_to_api_offering(offerings, request)
    render :json => offering_api.to_json, :callback => params[:callback]
  end

  # DEPRECIATED
  # This route is still used directly by https://github.com/concord-consortium/sharinator
  def for_class
    offering =  Portal::Offering.find(params[:id])
    params[:class_id] = offering.clazz.id
    own
  end

  # DEPRECIATED
  def for_teacher
    own
  end

  protected

  def offerings_to_api_offering(offerings, request)
    filtered_offerings = offerings.reject { |o| o.archived? }
    filtered_offerings.map do |offering|
      API::V1::Offering.new(offering, request.protocol, request.host_with_port)
    end
  end
end
