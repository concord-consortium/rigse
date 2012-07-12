class Admin::SiteNoticesController < ApplicationController
  def new
    unless current_user.has_role?('admin') or current_user.has_role?('manager')
      flash[:notice] = "Please log in as an administrator or manager"
      redirect_to(:home)
      return    
    end
  end

  def create
    site_notice = SiteNotice.new
    site_notice.notice_html = params[:notice_html]
    site_notice.creator_id = current_user.id
    site_notice.save!
    
    #storing all roles that should see this notice
    roles = params[:role]
    roles.each do |role_id|
      site_notice_roles = SiteNoticeRole.new
      site_notice_roles.notice_id = site_notice.id
      site_notice_roles.role_id = role_id  
    end
    redirect_to admin_site_notices_path
  end
  def index
    @all_notices = SiteNotice.all
  end
  def edit
    @all_notices = SiteNotice.all
    redirect_to admin_site_notices_path
  end
  
  def update
      #update notice
      site_notice = SiteNotice.find(params[:id])
      site_notice.notice_html= params[:notice_html]
      site_notice.creator_id = params[:creator_id]
      site_notice.save!
      
      #destroying all roles associated with current id
      roles=params[:roles]
      site_notice_id = SiteNoticeRole.find(params[:id])
      site_notice_id.each do |id|
         id.destroy
      end
      
      #Storing new roles
      roles = params[:roles]
      roles.each do |role_id|
      site_notice_roles = SiteNoticeRole.new
      site_notice_roles.notice_id = params[:id]
      site_notice_roles.role.id = role_id  
    end
      respond_to do |format|
      respond.html # update.html.erb
    end
  end
   
   def edit
      site_notice = SiteNotice.new
      site_notice.notice_html = params[:notice_html]
      site_notice.creator_id = current_user.id
      site_notice.save!
    
    #storing all roles that should see this notice
      roles = params[:role]
      roles.each do |role_id|
        site_notice_roles.notice_id = site_notice.id
        site_notice_roles = SiteNoticeRole.new
        site_notice_roles.role_id = role_id  
      end
      redirect_to admin_site_notices_path
   end
    
   def delete
      #delete notice
      SiteNotice.find(params[:id]).destroy
      SiteNoticeRole.find(params[:id]).destroy
      
      render :update do |page|
          page << "var element = $(#'temp');"
          page << "element.remove();"
      end
      
      #redirect_to :action => 'index';
      #redirect_to admin_site_notices_path
   end
  
    
end
