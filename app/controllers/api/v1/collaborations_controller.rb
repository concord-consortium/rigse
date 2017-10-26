class API::V1::CollaborationsController < API::APIController

  public

  # POST api/v1/collaborations
  # Note that owner of the collaboration is automatically added to its members.
  # There is no need to provide owner's data in 'students' parameter.
  def create
    authorize [:api, :v1, :collaboration]
    create_collaboration = API::V1::CreateCollaboration.new(create_input)
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
    authorize [:api, :v1, :collaboration]
    student_id = current_visitor.portal_student.id
    clazz = Portal::Offering.find(params[:offering_id]).clazz
    collaborators = clazz.students.select { |s| s.id != student_id }.map { |s| {:id => s.id, :name => s.name} }
    render json: collaborators
  end

  # GET api/v1/collaborations/:id/collaborators_data
  def collaborators_data
    authorize [:api, :v1, :collaboration]
    show_endpoints = API::V1::ShowCollaboratorsData.new(collaborators_data_input)
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
    result = params.permit(:offering_id, {students: [:id]})
    result[:owner_id] = current_visitor.portal_student && current_visitor.portal_student.id
    result[:host_with_port] = request.host_with_port
    result[:protocol] = request.protocol
    result
  end

  def collaborators_data_input
    {
      collaboration_id: params.require(:id),
      host_with_port: request.host_with_port,
      protocol: request.protocol
    }
  end

end
