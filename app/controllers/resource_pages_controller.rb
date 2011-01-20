class ResourcePagesController < ApplicationController
  before_filter :login_required
  before_filter :teacher_required, :except => [:show]
  before_filter :find_resource_page_and_verify_owner, :only => [:edit, :update, :destroy]
  
  def index
    @include_drafts = param_find(:include_drafts, true)
    @name = param_find(:name)
    
    @resource_pages = ResourcePage.search_list({
      :name => @name, 
      :user => current_user,
      :portal_clazz_id => @portal_clazz_id,
      :include_drafts => @include_drafts, 
      :paginate => true, 
      :page => params[:page]
    })
    
    if request.xhr?
      render :partial => 'runnable_list', :locals => { :resource_pages => @resource_pages, :paginated_objects => @resource_pages }
      return
    end
  end

  def show
    if current_user.has_role? 'admin'
      @resource_page = ResourcePage.find(params[:id])
    else
      @resource_page = ResourcePage.visible_to_user_with_drafts(current_user).find(params[:id])
    end
  end

  def new
    @resource_page = current_user.resource_pages.new
  end
  
  def create
    @resource_page = current_user.resource_pages.new(params[:resource_page])
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
    return if @resource_page.changeable?(current_user)
    flash[:error] = "You're not authorized to do this"
    redirect_to :home
  end
  
end