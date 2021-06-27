class API::V1::ProjectsController < API::APIController

  def index
    projects = Admin::Project.select {|p| policy(p).visible?}
    result = projects.map{ |p| {
      name: p.name,
      id: p.id,
      landing_page_slug: p.landing_page_slug,
      project_card_image_url: p.project_card_image_url,
      project_card_description: p.project_card_description,
      public: p.public} }
    render :json => result
  end

  def show
    project = Admin::Project
                   .where(id: params[:id])
                   .first
    unless project
      return error('project not found', 404)
    end
    authorize project, :api_show?
    render :json => project.to_json, :callback => params[:callback]
  end

end
