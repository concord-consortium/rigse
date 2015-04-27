class Admin::ProjectsController < ApplicationController
  include RestrictedController
  before_filter :admin_only

  # GET /admin/projects
  def index
    @projects = Admin::Project.search(params[:search], params[:page], nil)
  end

  # GET /admin/projects/1
  def show
    @project = Admin::Project.find(params[:id])
  end

  # GET /admin/projects/new
  def new
    @project = Admin::Project.new
  end

  # GET /admin/projects/1/edit
  def edit
    @project = Admin::Project.find(params[:id])

    if request.xhr?
      render :partial => 'remote_form', :locals => { :project => @project }
    end
  end

  # POST /admin/projects
  def create
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

    if request.xhr?
      @project.update_attributes(params[:admin_project])
      render :partial => 'show', :locals => { :project => @project }
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
