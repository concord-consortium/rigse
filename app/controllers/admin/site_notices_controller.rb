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
      site_notice_roles.save!
    end
    redirect_to admin_site_notices_path
  end
  
  def index
    @all_notices = SiteNotice.all
  end
  
  def edit
    @notice = SiteNotice.find(params[:id])
    @notice_roles = SiteNoticeRole.find_all_by_notice_id(params[:id])
    @notice_role_ids = @notice_roles.map{|notice_role| notice_role.role_id}
  end
  
  def update
      #Storing new html for notice
      site_notice = SiteNotice.find(params[:id])
      site_notice.notice_html= params[:notice_html]
      site_notice.updated_by = current_user.id
      site_notice.save!
      
      notice_roles = SiteNoticeRole.find_all_by_notice_id(params[:id])
      notice_roles.each do |notice_role|
        notice_role.destroy
      end
      
      #Storing new roles
      roles = params[:role]
      roles.each do |role_id|
        site_notice_roles = SiteNoticeRole.new
        site_notice_roles.notice_id = params[:id]
        site_notice_roles.role_id = role_id 
        site_notice_roles.save! 
      end
       
      redirect_to admin_site_notices_path
      
  end
   
    
   def remove_notice
      #delete notice
      
      notice_roles = SiteNoticeRole.find_all_by_notice_id(params[:id])
      notice_roles.each do |notice_role|
        notice_role.destroy
      end
      
      SiteNotice.find(params[:id]).destroy
      
      if request.xhr?
        render :update do |page|
            page << "$('#{params[:id]}').remove();"
        end
        return
      end
      
      #redirect_to :action => 'index';
      #redirect_to admin_site_notices_path
   end
  
    
end
