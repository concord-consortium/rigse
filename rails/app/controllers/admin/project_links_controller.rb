class Admin::ProjectLinksController < ApplicationController
  include RestrictedController

  before_action :check_for_project
  before_action :get_scoped_projects, only: ['new', 'edit', 'create', 'update']
  before_action :find_project_link, only: ['show', 'edit', 'update', 'destroy']

  private

  def check_for_project
    return unless params[:project_id]
    @project = Admin::Project.find(params[:project_id])
  end

  def get_scoped_projects
    @projects = policy_scope(Admin::Project)
    @projects = @projects.where(id: @project.id) if @project
  end

  def find_project_link
    @project_link = Admin::ProjectLink.find(params[:id])
  end

  protected

  def not_authorized_error_message
    super({resource_type: 'project link'})
  end

  public

  # GET /project_links or /admin/project/:project_id/project_links
  def index
    if @project
      # with a nested route only allow user which can edit the project
      authorize @project, :edit?
    end
    authorize Admin::ProjectLink
    search_scope = policy_scope(Admin::ProjectLink)
    search_scope = search_scope.where(project_id: @project.id) if @project
    @project_links = Admin::ProjectLink.search(params[:search], params[:page], nil, nil, search_scope)
    # render index.html.haml
  end

  # GET /project_links/1 or /admin/project/:project_id/project_links/:id
  def show
    authorize @project_link
    # render show.html.haml
  end

  # GET /project_links/new or /admin/project/:project_id/project_links/new
  def new
    if @project
      # with a nested route only allow user which can edit the project
      authorize @project, :edit?
    end
    authorize Admin::ProjectLink
    @project_link = Admin::ProjectLink.new
    @project_link.project_id = @project.id if @project
    # render new.html.haml
  end

  # GET /project_links/1/edit or /admin/project/:project_id/project_links/:id/edit
  def edit
    authorize @project_link
    # render edit.html.haml
  end

  # POST /project_links or /admin/project/:project_id/project_links
  def create
    @project_link = Admin::ProjectLink.new(admin_project_link_strong_params(params[:admin_project_link]))
    authorize @project_link
    if @project_link.save
      redirect_to @project_link, notice: 'Admin::ProjectLink was successfully created.'
    else
      render action: 'new'
    end
  end

  # PUT /project_links/1 or /admin/project/:project_id/project_links/:id
  def update
    authorize @project_link
    # this also has the side effect that a invalid project will raise a record not found
    new_project = Admin::Project.find(params[:admin_project_link][:project_id])
    authorize new_project, :edit?
    if @project_link.update(admin_project_link_strong_params(params[:admin_project_link]))
      redirect_to @project_link, notice: 'Admin::ProjectLink was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /project_links/1 or /admin/project/:project_id/project_links/:id
  def destroy
    authorize @project_link
    @project_link.destroy
    flash['notice'] = "Link #{@project_link.name} was deleted"
    redirect_back_or admin_project_links_url
  end

  def admin_project_link_strong_params(params)
    params && params.permit(:href, :link_id, :name, :pop_out, :position, :project_id)
  end
end
