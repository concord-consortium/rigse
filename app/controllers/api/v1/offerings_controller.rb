class API::V1::OfferingsController < API::APIController

  private
  def pundit_user_not_authorized(exception)
    render status: 403, json: {
        success: false,
        message: 'Not authorized'
    }
  end


  public
  def show
    offering = Portal::Offering.find(params[:id], include: {
        learners: {student: :user},
        clazz: {students: :user}
    })
    authorize offering, :api_show?
    @offering_api = API::V1::Offering.new(offering, request.protocol, request.host_with_port)
    render :json => @offering_api.to_json, :callback => params[:callback]
  end

  # Return a list for all of the classes
  def for_class
    offering =  Portal::Offering.find(params[:id])
    authorize offering, :api_show?
    offerings = offering.clazz.offerings(include: {learners: {student: :user}, clazz: {students: :user}})
    @offering_api = offerings.map do |offering|
      API::V1::Offering.new(offering, request.protocol, request.host_with_port)
    end
    render :json => @offering_api.to_json, :callback => params[:callback]
  end

  # return a list for the teachers
  def for_teacher
    offering = Portal::Offering.find(params[:id])
    authorize offering, :api_show?
    teacher = offering.clazz.teacher
    clazz_ids = teacher.clazz_ids
    offerings = Portal::Offering
                    .where("clazz_id", clazz_ids)
                    .includes(learners: {student: :user}, clazz: {students: :user})

    @offering_api = offerings.map do |offering|
      API::V1::Offering.new(offering, request.protocol, request.host_with_port)
    end
    render :json => @offering_api.to_json, :callback => params[:callback]
  end


end

