class API::V1::CollaborationsController < API::APIController

  def create
    return error("unauthorized", 401) unless can_create_collaboration
    create_collaboration = API::V1::CreateCollaboration.new(create_collaboration_params)
    if create_collaboration.call
      render status: 201, json: create_collaboration.attributes
    else
      error(create_collaboration.errors)
    end
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

end
