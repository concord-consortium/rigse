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
    authorize offering, :api_show?
    @offering_api = API::V1::Offering.new(offering, request.protocol, request.host_with_port)
    render :json => @offering_api.to_json, :callback => params[:callback]
  end

  # Return a list for all of the classes
  def for_class
    offering =  Portal::Offering.find(params[:id])
    authorize offering, :api_show?
    offerings = Portal::Offering
                    .where(clazz_id: offering.clazz.id)
                    .includes(INCLUDES_DEF)
    offering_api = offerings_to_api_offering(offerings, request)
    render :json => offering_api.to_json, :callback => params[:callback]
  end

  # return a list for the teachers
  def for_teacher
    offering = Portal::Offering.find(params[:id])
    authorize offering, :api_show?
    teacher = offering.clazz.teacher
    clazz_ids = teacher.clazz_ids
    offerings = Portal::Offering
                    .where(clazz_id: clazz_ids)
                    .includes(INCLUDES_DEF)
    offering_api = offerings_to_api_offering(offerings, request)
    render :json => offering_api.to_json, :callback => params[:callback]
  end

  # Returns a list for the currently logged in user (teacher).
  # Pretty similar to to #for_teacher but without awkward teacher lookup (current user is used instead).
  def for_current_user
    authorize Portal::Offering, :api_for_current_user?
    clazz_ids = current_user.portal_teacher.clazz_ids
    offerings = Portal::Offering
                    .where(clazz_id: clazz_ids)
                    .includes(INCLUDES_DEF)
    offering_api = offerings_to_api_offering(offerings, request)
    render :json => offering_api.to_json, :callback => params[:callback]
  end

  protected

  def offerings_to_api_offering(offerings, request)
    filtered_offerings = offerings.reject { |o| o.archived? }
    filtered_offerings.map do |offering|
      API::V1::Offering.new(offering, request.protocol, request.host_with_port)
    end
  end

end

