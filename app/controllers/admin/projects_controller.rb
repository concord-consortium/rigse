class Admin::ProjectsController < ApplicationController

  protected

  def not_authorized_error_message
    super({resource_type: 'project'})
  end

  public

  # GET /:landing_page_slug
  def landing_page
    # no authorization needed ...
    @project = Admin::Project.where(landing_page_slug: params[:landing_page_slug]).first!

    @landing_page_content = @project.landing_page_content
    # Redirect back to project landing page after user signs in.
    @after_sign_in_path = request.path
    # set page title tag and meta tag values
    page_meta = {
      :meta_tags => {},
      :open_graph => {}
    }
    @page_title = @project.name
    meta_tags = page_meta[:meta_tags]
    meta_tags[:description] = @project.project_card_description
    if meta_tags[:description].blank?
      meta_tags[:description] = "Check out this collection of educational resources from the Concord Consortium."
    end
    open_graph = page_meta[:open_graph]
    open_graph[:title] = @page_title
    open_graph[:description] = meta_tags[:description]
    open_graph[:image] = @project.project_card_image_url
    if open_graph[:image].blank?
      open_graph[:image] = "https://learn-resources.concord.org/images/stem-resources/stem-resource-finder.jpg"
    end
    @open_graph = page_meta[:open_graph]

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
