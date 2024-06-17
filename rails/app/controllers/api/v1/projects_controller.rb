class API::V1::ProjectsController < API::APIController

  def index
    projects = Admin::Project.select { |p| policy(p).visible? }
    result = projects.map { |p| project_to_hash(p) }
    render json: result
  end

  # Returns all the projects that user has a full access to.
  def index_with_permissions
    projects = policy_scope(Admin::Project)
    result = projects.map { |p| project_to_hash(p) }
    render json: result
  end

  def show
    project = Admin::Project.find(params[:id])
    authorize project, :api_show?
    render :json => project.to_json, :callback => params[:callback]
  end

  def parameter_missing(exception)
    render status: 400, json: {
      success: false,
      message: exception.message
    }
  end

  private

  def project_to_hash(project)
    {
      name: project.name,
      id: project.id,
      landing_page_slug: project.landing_page_slug,
      project_card_image_url: project.project_card_image_url,
      project_card_description: project.project_card_description,
      public: project.public
    }
  end

end
