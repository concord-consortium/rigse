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

end
