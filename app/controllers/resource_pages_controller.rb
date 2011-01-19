class ResourcePagesController < ApplicationController
  before_filter :login_required
  before_filter :teacher_required, :except => [:show]
  before_filter :find_resource_page_and_verify_owner, :only => [:edit, :update, :destroy]
  
  def index
    @resource_pages = ResourcePage.all
  end

  def show
    @resource_page = ResourcePage.published_or_by_user(current_user).find(params[:id])
  end

  def new
    @resource_page = ResourcePage.new
    @resource_page.user = current_user
  end
  
  def create
    @resource_page = ResourcePage.new(params[:resource_page])
    @resource_page.user = current_user
    unless @resource_page.save
      render :action => 'new' and return
    end
    
    @resource_page.new_attached_files = params[:attached_files]
    flash[:notice] = "Resource Page was successfully created."
    redirect_to @resource_page
  end

  def edit
  end
  
  def update
    unless @resource_page.update_attributes(params[:resource_page].merge({:new_attached_files => params[:attached_files]}))
      render :action => 'edit' and return
    end
    
    flash[:notice] = "Successfully updated this resource page"
    redirect_to @resource_page
  end
  
  def destroy
    @resource_page.destroy
    redirect_to resource_pages_path
  end
  
protected
  
  def teacher_required
    return if logged_in? && (current_user.portal_teacher || current_user.has_role?("admin"))
    flash[:error] = "You're not authorized to do this"
    redirect_to :home
  end
  
  def find_resource_page_and_verify_owner
    @resource_page = ResourcePage.find(params[:id])
    return if @resource_page.user == current_user
    flash[:error] = "You're not authorized to do this"
    redirect_to :home
  end
  
end
