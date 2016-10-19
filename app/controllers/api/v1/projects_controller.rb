class API::V1::ProjectsController < API::APIController

  def index
    @projects = Portal::Project.all.map{ |c| {name: c.name, id: c.id, landing_page_slug: c.landing_page_slug, project_card_image_url: c.project_card_image_url, project_card_description: c.project_card_description, public: c.public} }
    render :json => @projects
  end

end
