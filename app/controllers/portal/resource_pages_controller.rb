class Portal::ResourcePagesController < ApplicationController
  before_filter :login_required
  before_filter :teacher_required, :except => [:show]
  before_filter :find_resource_page_and_verify_owner, :only => [:edit, :update, :destroy]
  
  def index
    @portal_resource_pages = Portal::ResourcePage.all
  end

  def show
    # TODO: don't show "draft" pages to non-creators
    @portal_resource_page = Portal::ResourcePage.published_or_by_user(current_user).find(params[:id])
  end

  def new
    @portal_resource_page = Portal::ResourcePage.new
    @portal_resource_page.user = current_user
  end
  
  def create
    @portal_resource_page = Portal::ResourcePage.new(params[:portal_resource_page])
    @portal_resource_page.user = current_user
    unless @portal_resource_page.save
      render :action => 'new' and return
    end
    
    flash[:notice] = "Successfully created Resource Page"
    redirect_to @portal_resource_page
  end

  def edit
  end
  
  def update
    unless @portal_resource_page.update_attributes(params[:portal_resource_page])
      render :action => 'edit' and return
    end
    
    flash[:notice] = "Successfully updated this resource page"
    redirect_to @portal_resource_page
  end
  
  def destroy
    @portal_resource_page.destroy
    redirect_to portal_resource_pages_path
  end
  
protected
  
  def teacher_required
    return if logged_in? && (current_user.portal_teacher || current_user.has_role?("admin"))
    flash[:error] = "You're not authorized to do this"
    redirect_to :home
  end
  
  def find_resource_page_and_verify_owner
    @portal_resource_page = Portal::ResourcePage.find(params[:id])
    return if @portal_resource_page.user == current_user
    flash[:error] = "You're not authorized to do this"
    redirect_to :home
  end
  
end
