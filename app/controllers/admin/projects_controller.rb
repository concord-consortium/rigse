class Admin::ProjectsController < ApplicationController
  include RestrictedController
  # PUNDIT_CHECK_FILTERS
  before_filter :admin_only, except: [:landing_page]

  # GET /:landing_page_slug
  def landing_page
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Admin::Project
    # authorize @project
    # authorize Admin::Project, :new_or_create?
    # authorize @project, :update_edit_or_destroy?
    @project = Admin::Project.where(landing_page_slug: params[:landing_page_slug]).first!
    @landing_page_content = @project.landing_page_content
  end

  # GET /admin/projects
  def index
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    authorize Admin::Project
    @projects = Admin::Project.search(params[:search], params[:page], nil)
    # PUNDIT_REVIEW_SCOPE
    # PUNDIT_CHECK_SCOPE (found instance)
    @projects = policy_scope(Admin::Project)
  end

  # GET /admin/projects/1
  def show
    @project = Admin::Project.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    authorize @project
  end

  # GET /admin/projects/new
  def new
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    authorize Admin::Project
    @project = Admin::Project.new
    @project.links.build
  end

  # GET /admin/projects/1/edit
  def edit
    @project = Admin::Project.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    authorize @project

    if request.xhr?
      render :partial => 'remote_form', :locals => { :project => @project }
    end
  end

  # POST /admin/projects
  def create
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
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
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
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
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    authorize @project
    Admin::Project.find(params[:id]).destroy

    redirect_to admin_projects_url
  end

  private

  def admin_only
    unless current_visitor.has_role?('admin')
      flash[:notice] = 'Please log in as an administrator'
      redirect_to(:home)
    end
  end
end
