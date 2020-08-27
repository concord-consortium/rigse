class Admin::ProjectLinksController < ApplicationController
  include RestrictedController

  before_filter :get_scoped_projects, only: ['new', 'edit']
  before_filter :find_project_link, only: ['show', 'edit', 'update', 'destroy']
  before_filter :check_for_project

  def check_for_project
    return unless params[:project_id]

    @project = Admin::Project.find(params[:project_id])
    authorize @project
  end

  private

  def get_scoped_projects
    @projects = policy_scope(Admin::Project)
  end

  def find_project_link
    @project_link = Admin::ProjectLink.find(params[:id])
  end

  public

  # GET /project_links
  def index
    authorize Admin::ProjectLink

    @project_links = Admin::ProjectLink.search(params[:search], params[:page], nil, nil, policy_scope(Admin::ProjectLink))
    # render index.html.haml
  end

  # GET /project_links/1
  def show
    authorize @project_link
    # render show.html.haml
  end

  # GET /project_links/new
  def new
    authorize Admin::ProjectLink
    @project_link = Admin::ProjectLink.new
    # render new.html.haml
  end

  # GET /project_links/1/edit
  def edit
    authorize @project_link
    # render edit.html.haml
  end

  # POST /project_links
  def create
    @project_link = Admin::ProjectLink.new(params[:admin_project_link])
    authorize @project_link
    if @project_link.save
      redirect_to @project_link, notice: 'Admin::ProjectLink was successfully created.'
    else
      render action: 'new'
    end
  end

  # PUT /project_links/1
  def update
    authorize @project_link
    if @project_link.update_attributes(params[:admin_project_link])
      redirect_to @project_link, notice: 'Admin::ProjectLink was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /project_links/1
  def destroy
    authorize @project_link
    @project_link.destroy
    redirect_to admin_project_links_url, notice: "Link #{@project_link.name} was deleted"
  end
end
