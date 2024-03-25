class Admin::ProjectsController < ApplicationController

  protected

  def humanized_action(map = {})
    super({landing_page: 'view'})
  end

  def not_authorized_error_message
    if action_name == 'landing_page'
      super({resource_type: 'collection'})
    else
      super({resource_type: 'project'})
    end
  end

  public

  # GET /:landing_page_slug
  def landing_page    # no authorization needed ...
    @project = Admin::Project.where(landing_page_slug: params[:landing_page_slug]).first!

    # We want to prevent logged in students from viewing landing pages
    authorize @project

    @landing_page_content = @project.landing_page_content
    # Redirect back to project landing page after user signs in.
    @after_sign_in_path = request.path
    # set page title tag and meta tag values
    @page_title = @project.name
    @open_graph = {
      title: @page_title,
      description: @project.project_card_description ||
        "Check out this collection of educational resources from the Concord Consortium.",
      image: @project.project_card_image_url ||
        "https://learn-resources.concord.org/images/stem-resources/stem-resource-finder.jpg"
    }
    render layout: 'minimal'

    # if portal user is a teacher, update their recently visited collections pages
    if (@portal_teacher.present?)
      @portal_teacher.record_project_view(@project)
    end
  end

  # GET /admin/projects
  def index
    authorize Admin::Project
    @projects = policy_scope(Admin::Project).search(params[:search], params[:page], nil)
  end

  # GET /admin/projects/1
  def show
    @project = Admin::Project.find(params[:id])
    authorize @project
  end

  # GET /admin/projects/new
  def new
    authorize Admin::Project
    @project = Admin::Project.new
    @project.links.build
  end

  # GET /admin/projects/1/edit
  def edit
    @project = Admin::Project.find(params[:id])
    authorize @project
    # renders edit.html.haml
  end

  # GET /admin/projects/1/research_classes
  def research_classes
    @project = Admin::Project.find(params[:id])
    authorize @project
    # renders research_classes.html.haml
  end

  # POST /admin/projects
  def create
    authorize Admin::Project
    @project = Admin::Project.new(admin_project_strong_params(params[:admin_project]))

    if @project.save
      redirect_to admin_projects_url, notice: 'Project was successfully created.'
    else
      render action: 'new'
    end
  end

  # PUT /admin/projects/1
  def update
    @project = Admin::Project.find(params[:id])
    authorize @project
    if @project.update(admin_project_strong_params(params[:admin_project]))
      redirect_to @project, notice: 'Project was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /admin/projects/1
  def destroy
    @project = Admin::Project.find(params[:id])
    authorize @project
    @project.destroy
    redirect_to admin_projects_url
  end

  private

  def project_params
    params.require(:admin_project).permit(policy(@project).permitted_attributes)
  end


  def admin_project_strong_params(params)
    params && params.permit(:landing_page_content, :landing_page_slug, :name, :project_card_description, :project_card_image_url, :public)
  end
end
