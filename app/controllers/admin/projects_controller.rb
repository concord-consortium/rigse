class Admin::ProjectsController < ApplicationController

  rescue_from Pundit::NotAuthorizedError, with: :pundit_user_not_authorized

  private

  def pundit_user_not_authorized(exception)
    flash[:notice] = "Please log in as an administrator"
    redirect_to(:home)
  end

  public

  # GET /:landing_page_slug
  def landing_page
    # no authorization needed ...
    @project = Admin::Project.where(landing_page_slug: params[:landing_page_slug]).first!
    @landing_page_content = @project.landing_page_content
  end

  # GET /admin/projects
  def index
    authorize Admin::Project
    @projects = Admin::Project.search(params[:search], params[:page], nil)
    # PUNDIT_REVIEW_SCOPE
    # PUNDIT_CHECK_SCOPE (found instance)
    # @projects = policy_scope(Admin::Project)
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

    if request.xhr?
      render :partial => 'remote_form', :locals => { :project => @project }
    end
  end

  # POST /admin/projects
  def create
    authorize Admin::Project
    @project = Admin::Project.new(params[:admin_project])

    if @project.save
      redirect_to admin_projects_url, :notice => 'Project was successfully created.'
    else
      render :action => 'new'
    end
  end

  # PUT /admin/projects/1
  def update
    @project = Admin::Project.find(params[:id])
    authorize @project

    if request.xhr?
      if @project.update_attributes(params[:admin_project])
        render :partial => 'show', :locals => { :project => @project }
      else
        render :partial => 'remote_form', :locals => { :project => @project }, :status => 400
      end
    else
      if @project.update_attributes(params[:admin_project])
        redirect_to @project, :notice => 'Project was successfully updated.'
      else
        render :action => 'edit'
      end
    end
  end

  # DELETE /admin/projects/1
  def destroy
    @project = Admin::Project.find(params[:id])
    authorize @project
    @project.destroy

    redirect_to admin_projects_url
  end

end
