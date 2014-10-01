class API::V1::CollaborationsController < API::APIController

  # POST api/v1/collaborations
  def create
    return unauthorized unless can_create_collaboration
    create_collaboration = API::V1::CreateCollaboration.new(create_collaboration_params)
    if create_collaboration.call
      render status: 201, json: create_collaboration.attributes
    else
      error(create_collaboration.errors)
    end
  end

  # GET api/v1/collaborations/available_collaborators?offering_id=:id
  def available_collaborators
    offering_id = params.require(:offering_id)
    clazz = Portal::Offering.find(offering_id).clazz
    return unauthorized unless can_list_collaborators(clazz)
    render json: clazz.to_api_json[:students]
  end

  private

  def create_collaboration_params
    result = params.permit(:offering_id, {:students => [:id, :password]}, :external_activity)
    # Authorization should ensure that portal_student is defined.
    result[:owner_id] = current_visitor.portal_student.id
    result
  end

  # TODO: move to separate class once authorization gets more complicated (will be for sure for #show action).
  def can_create_collaboration
    !current_visitor.portal_student.nil?
  end

  def can_list_collaborators(clazz)
    return false if current_user.nil?
    # User has to be member of a class (its student or teacher).
    student = current_user.portal_student
    clazz.students.include?(student)
  end

end
