class SiteNoticesController < ApplicationController
  def new
    unless current_user.has_role('admin') and current_user.has_role('manager') then
      flash[:notice] = "Please log in as an administrator or manager"
      redirect_to(:home)
      return    
    end
    @site_notice = SiteNotice.new
    respond_to do |format|
      respond.html # new.html.erb
    end
  end
  def create
    site_notice = SiteNotice.new
    site_notice.notice_html = params[:notice_html]
    site_notice.creator_id = params[:creator_id]
    site_notice.save!
    
    #storing all roles that should see this notice
    roles.each do |role_id|
      site_notice_roles = SiteNoticeRole.new
      site_notice_roles.notice_id = site_notice.id
      site_notice_roles.role.id = role_id  
    end
    
    #storing all the users who should see this notice. All this notice are non collapsed 
      
    respond_to do |format|
      respond.html # create.html.erb
    end
  end
end
