class Admin::ProjectsController < ApplicationController
  
  before_filter :admin_only, :except => [:index, :edit, :update]
  before_filter :admin_or_manager, :only => [:index, :edit, :update]
  # before_filter :setup_object, :except => [:index]
  # before_filter :render_scope, :only => [:show]

  # editing / modifying / deleting require editable-ness
  # before_filter :can_edit, :except => [:index,:show,:print,:create,:new,:duplicate,:export] 
  # before_filter :can_create, :only => [:new, :create,:duplicate]
  # 
  # in_place_edit_for :activity, :name
  # in_place_edit_for :activity, :description
  
  protected 

  def admin_only
    unless current_user.has_role?('admin')
      flash[:notice] = "Please log in as an administrator" 
      redirect_to(:home)
    end
  end
  
  def admin_or_manager
    if current_user.has_role?('admin')
      @admin_role = true
    elsif current_user.has_role?('manager')
      @manager_role = true
    else
      flash[:notice] = "Please log in as an administrator or manager" 
      redirect_to(:home)
    end
  end
  
  public
  
  # GET /admin/projects
  # GET /admin/projects.xml
  def index
    default_project = Admin::Project.default_project
    
    if @manager_role
      @admin_projects = [default_project].paginate
    else
      # convert from ActiveRecord::Relation to a collection
      # because delete bellow will remove from db otherwise
      @admin_projects = Admin::Project.search(params[:search], params[:page], nil).to_a
    end

    # If default_project is in collection to be displayed then put it first.
    unless @admin_projects.length <= 1 || @admin_projects[0].default_project?
      if @admin_projects.delete(default_project)
        @admin_projects.unshift(default_project)
      end
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @admin_projects }
    end
  end

  # GET /admin/projects/1
  # GET /admin/projects/1.xml
  def show
    @admin_project = Admin::Project.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @admin_project }
    end
  end

  # GET /admin/projects/new
  # GET /admin/projects/new.xml
  def new
    @admin_project = Admin::Project.new
    @scope = nil
    

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @admin_project }
    end
  end

  # GET /admin/projects/1/edit
  def edit
    @admin_project = Admin::Project.find(params[:id])
    
    # Pull in the current theme default home page content, if it isn't set in the project.
    if @admin_project.home_page_content.nil? || @admin_project.home_page_content.empty?
      render_to_string :partial => "home/project_info"
      
      @admin_project.home_page_content = view_context.instance_variable_get(:@content_for_project_info)
      view_context.instance_variable_set(:@content_for_project_info, nil)
    end
    
    if request.xhr?
      render :partial => 'remote_form', :locals => { :admin_project => @admin_project }
    end
  end

  # POST /admin/projects
  # POST /admin/projects.xml
  def create
    @admin_project = Admin::Project.new(params[:admin_project])
    respond_to do |format|
      if @admin_project.save
        flash[:notice] = 'Admin::Project was successfully created.'
        format.html { redirect_to(@admin_project) }
        format.xml  { render :xml => @admin_project, :status => :created, :location => @admin_project }
      else
        format.html { redirect_to(new_admin_project_url) }
        format.xml  { render :xml => @admin_project.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin/projects/1
  # PUT /admin/projects/1.xml
  def update
    @admin_project = Admin::Project.find(params[:id])
    if request.xhr?
      @admin_project.update_attributes(params[:admin_project])
      render :partial => 'show', :locals => { :admin_project => @admin_project }
    else
      respond_to do |format|
        if @admin_project.update_attributes(params[:admin_project])
          flash[:notice] = 'Admin::Project was successfully updated.'
          format.html { redirect_to(@admin_project) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @admin_project.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /admin/projects/1
  # DELETE /admin/projects/1.xml
  def destroy
    @project = Admin::Project.find(params[:id])
    @project.destroy

    respond_to do |format|
      format.html { redirect_to(admin_projects_url) }
      format.xml  { head :ok }
    end
  end
  
end
