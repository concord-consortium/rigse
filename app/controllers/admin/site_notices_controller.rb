class Admin::SiteNoticesController < ApplicationController
  before_filter :admin_or_manager, :except => [:toggle_notice_display, :dismiss_notice]
  
  protected
  
  def admin_or_manager
    unless current_user.has_role?('admin') or current_user.has_role?('manager')
      flash[:error] = "Please log in as an administrator or manager"
      redirect_to(:home)
    end
  end
  
  public
  
  def new
    @all_roles_selected_by_default = true
    @role_ids = []
    @notice_html = ''
  end

  def create
    error = nil
    @notice_html = params[:notice_html] ? params[:notice_html] : ''
    @role_ids = params[:role] ? params[:role] : []
    @all_roles_selected_by_default = false
    
    @notice_html = '' if @notice_html == '<html />' #fix for IE 9. IE 9 sends '<html />' for blank text
    
    unless ActionController::Base.helpers.strip_tags(@notice_html).gsub('&nbsp;', ' ').strip =~ /\S+/
      error = "Notice text is blank"
    end
    
    if @role_ids.count == 0
      error = error ? error + "<br>No role is selected</br>" : "" +  "No role is selected"
    end
    
    @role_ids.map!{|a| a.to_i }
    
    if error
      flash[:error] = error.html_safe
      respond_to do |format|
        format.html { render :action => "new" }
      end
      return
    end
    
    site_notice = Admin::SiteNotice.new
    site_notice.notice_html = @notice_html
    site_notice.created_by = current_user.id
    site_notice.updated_by = current_user.id
    site_notice.save!
    
    #storing all roles that should see this notice
    
    @role_ids.each do |role_id|
      site_notice_role = Admin::SiteNoticeRole.new
      site_notice_role.notice_id = site_notice.id
      site_notice_role.role_id = role_id
      site_notice_role.save!
    end
    
    redirect_to admin_site_notices_path
  end
  
  def index
     @all_notices = Admin::SiteNotice.find(:all,:order=> 'updated_at desc') 
  end
  
  def edit
    @notice = Admin::SiteNotice.find(params[:id])
    @notice_html = @notice.notice_html
    @notice_roles = Admin::SiteNoticeRole.find_all_by_notice_id(params[:id])
    @notice_role_ids = @notice_roles.map{|notice_role| notice_role.role_id}
  end
  
  def update
    
    @notice = Admin::SiteNotice.find(params[:id])
    @notice_roles = Admin::SiteNoticeRole.find_all_by_notice_id(params[:id])
    
    @notice_html = params[:notice_html]
    
    @notice_role_ids = params[:role].nil? ? [] : params[:role]
    @notice_role_ids.map! {|nr| nr.to_i}
    
    unless ActionController::Base.helpers.strip_tags(@notice_html).gsub('&nbsp;', ' ').strip =~ /\S+/
      error = "Notice text is blank"
    end
    
    if @notice_role_ids.count == 0
      error = error ? error + "<br>No role is selected</br>" : "" +  "No role is selected"
    end
    
    if error
      flash[:error] = error.html_safe
      respond_to do |format|
        format.html { render :action => "edit" }
      end
      return
    end
    
    site_notice = @notice
    site_notice.notice_html= @notice_html
    site_notice.updated_by = current_user.id
    site_notice.save!
    
    notice_role_ids = @notice_roles.map {|nr| nr.id}
    Admin::SiteNoticeRole.delete(notice_role_ids)
    
    #Storing new roles
    @notice_role_ids.each do |role_id|
      site_notice_role = Admin::SiteNoticeRole.new
      site_notice_role.notice_id = @notice.id
      site_notice_role.role_id = role_id
      site_notice_role.save!
    end
    
    redirect_to admin_site_notices_path
  end
   
    
  def remove_notice
    #delete notice
    notice_roles = Admin::SiteNoticeRole.find_all_by_notice_id(params[:id])
    notice_roles.each do |notice_role|
      notice_role.destroy
    end
    
    notice_users = Admin::SiteNoticeUser.find_all_by_notice_id(params[:id])
    notice_users.each do |notice_user|
      notice_user.destroy
    end
        
    Admin::SiteNotice.find(params[:id]).destroy
    
    if request.xhr?
      render :update do |page|
        page << "$('#{params[:id]}').remove();"
        page << "notices_table = document.getElementById('notice_list')"
        page << "all_notices = notices_table.getElementsByTagName('tr')"
        page << "if(all_notices.length == 1)"
        page << "{"
        page << "$('notice_list').remove();"
        page << "$('no_notice_msg').update('You have no notices.<br/>To create a notice click the \"Create New Notice\" button.')"
        page << "}"
      end
      return
    end
    
    #redirect_to :action => 'index';
    #redirect_to admin_site_notices_path
  end
  

  def toggle_notice_display
    user_collapsed_notice = Admin::NoticeUserDisplayStatus.find_or_create_by_user_id(current_user.id)
    status_to_be_set = (user_collapsed_notice.collapsed_status.nil? || user_collapsed_notice.collapsed_status == false)? true : false
    
    user_collapsed_notice.last_collapsed_at_time = DateTime.now
    user_collapsed_notice.collapsed_status = status_to_be_set
    user_collapsed_notice.save!
    if request.xhr?
      render(:update) { |page| }
      return 
    end
  end
  
  def dismiss_notice
    notice = Admin::SiteNotice.find(params[:id])
    user_notice = Admin::SiteNoticeUser.find_or_create_by_notice_id_and_user_id(notice.id , current_user.id)
    user_notice.notice_dismissed = true
    user_notice.updated_at = DateTime.now
    user_notice.save!
    if request.xhr?
      render :update do |page|
        page << "$('#{dom_id_for(notice)}').remove();"
        page << "notice_table = document.getElementById('all_notice_to_render')
                  all_notices = notice_table.getElementsByTagName('tr')
                  if(all_notices.length == 0)
                  {
                    $('oHideShowLink').remove();
                    $('notice_container').remove();
                  }
                "
      end
      return
    end
  end
    
end
