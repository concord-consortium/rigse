class Admin::SiteNoticesController < ApplicationController
  def new
    unless current_user.has_role?('admin') or current_user.has_role?('manager')
      flash[:notice] = "Please log in as an administrator or manager"
      redirect_to(:home)
      return    
    end
  end

  def create
    if params[:notice_html] =~ /\S+/
      if !params[:role].nil?
        site_notice = Admin::SiteNotice.new
        site_notice.notice_html = params[:notice_html]
        site_notice.created_by = current_user.id
        site_notice.save!
        
        #storing all roles that should see this notice
        
        roles = params[:role]
        roles.each do |role_id|
          site_notice_roles = Admin::SiteNoticeRole.new
          site_notice_roles.notice_id = site_notice.id
          site_notice_roles.role_id = role_id
          site_notice_roles.save!
        end
      else
        flash[:error] = "Select atleast one role"
      end       
    else
      flash[:error] = "Text cannot be blank"
    end
    redirect_to admin_site_notices_path
  end
  
  def index
     unless current_user.has_role?('admin') or current_user.has_role?('manager')
      flash[:notice] = "Please log in as an administrator or manager"
      redirect_to(:home)
      return
     end
     @all_notices = Admin::SiteNotice.all  
  end
  
  def edit
    unless current_user.has_role?('admin') or current_user.has_role?('manager')
      flash[:notice] = "Please log in as an administrator or manager"
      redirect_to(:home)
      return
    end  
    @notice = Admin::SiteNotice.find(params[:id])
    @notice_roles = Admin::SiteNoticeRole.find_all_by_notice_id(params[:id])
    @notice_role_ids = @notice_roles.map{|notice_role| notice_role.role_id}
  end
  
  def update
    #Storing new html for notice
    if params[:notice_html] =~ /\S+/
      if !params[:role].nil?
        site_notice = Admin::SiteNotice.find(params[:id])
        site_notice.notice_html= params[:notice_html]
        site_notice.updated_by = current_user.id
        site_notice.save!
          
        notice_roles = Admin::SiteNoticeRole.find_all_by_notice_id(params[:id])
        notice_roles.each do |notice_role|
          notice_role.destroy
        end
          
        #Storing new roles
        roles = params[:role]
        roles.each do |role_id|
          site_notice_roles = Admin::SiteNoticeRole.new
          site_notice_roles.notice_id = params[:id]
          site_notice_roles.role_id = role_id 
          site_notice_roles.save!
        end
      else
        flash[:error] = "Select atleast one role"
      end
    else
      flash[:error] = "Text cannot be blank"
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
        page << "$('notice_list').remove();"
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
    user_notice = Admin::SiteNoticeUser.new
    user_notice.user_id = current_user.id
    user_notice.notice_id = params[:id]
    user_notice.notice_dismissed = 1
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
