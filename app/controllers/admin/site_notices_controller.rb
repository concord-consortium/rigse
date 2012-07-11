class Admin::SiteNoticesController < ApplicationController
  def new
    unless current_user.has_role?('admin') or current_user.has_role?('manager')
      flash[:notice] = "Please log in as an administrator or manager"
      redirect_to(:home)
      return    
    end
    @site_notice = SiteNotice.new
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
    @all_notices = SiteNotice.all
  end
  def index
    current_user_id = current_user.id
    @all_notices = SiteNotice.all
  end
end
