class API::V1::CollaborationsController < API::APIController
  include PeerAccess
  # POST api/v1/collaborations
  # Note that owner of the collaboration is automatically added to its members.
  # There is no need to provide owner's data in 'students' parameter.
  def create
    input = create_input
    return unauthorized unless create_auth(input)
    create_collaboration = API::V1::CreateCollaboration.new(input)
    result = create_collaboration.call
    if result
      render status: 201, json: result
    else
      error(create_collaboration.errors)
    end
  end

  # GET api/v1/collaborations/available_collaborators?offering_id=:id
  # Returns all the students in the same class without student that is currently signed in.
  def available_collaborators
    input = available_collaborators_input
    return unauthorized unless available_collaborators_auth(input)
    student_id = current_visitor.portal_student.id
    clazz = Portal::Offering.find(input[:offering_id]).clazz
    collaborators = clazz.students.select { |s| s.id != student_id }.map { |s| {:id => s.id, :name => s.name} }
    render json: collaborators
  end

  # GET api/v1/collaborations/:id/collaborators_data
  def collaborators_data
    input = collaborators_data_input
    return unauthorized unless collaborators_data_auth(input)
    show_endpoints = API::V1::ShowCollaboratorsData.new(input)
    result = show_endpoints.call
    if result
      render json: result
    else
      error(show_endpoints.errors)
    end
  end

  private

  # Input handling

  def create_input
    result = params.permit(:offering_id, {students: [:id, :password]})
    result[:owner_id] = current_visitor.portal_student && current_visitor.portal_student.id
    result[:host_with_port] = request.host_with_port
    result[:protocol] = request.protocol
    result
  end

  def available_collaborators_input
    {
      offering_id: params.require(:offering_id)
    }
  end

  def collaborators_data_input
    {
      collaboration_id: params.require(:id),
      host_with_port: request.host_with_port,
      protocol: request.protocol
    }
  end

  # Authorization
  # TODO: move to separate class?

  def create_auth(input)
    class_member(input)
  end

  def available_collaborators_auth(input)
    class_member(input)
  end

  def collaborators_data_auth(input)
    verify_request_is_peer
  end

  def class_member(input)
    return false if current_user.nil?
    offering = Portal::Offering.find(input[:offering_id])
    clazz = offering.clazz
    student = current_user.portal_student
    clazz.students.include?(student)
  end

end
