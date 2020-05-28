class API::V1::SiteNoticesController < API::APIController

  before_filter :admin_or_manager, :except => [:get_notices_for_user, :toggle_notice_display, :dismiss_notice]

  # TODO: figure out why rspec is breaking and add authorization back (and remove before_filter)

  protected

  def admin_or_manager
    unless current_visitor.has_role?('admin') or current_visitor.has_role?('manager')
      raise Pundit::NotAuthorizedError
    end
  end

  public

  def get_notices_for_user
    notices_hash = Admin::SiteNotice.get_notices_for_user(current_visitor)
    @notice_display_type = notices_hash[:notice_display_type]
    @notices = notices_hash[:notices]
    render json: @notices
  end

  def new
    #authorize Admin::SiteNotice
    @action_type = 'Create Notice'
    @all_roles_selected_by_default = true
    @notice_role_ids = []
    @notice_html = '<p> </p>' #fix for IE 9
  end

  def create
    #authorize Admin::SiteNotice
    error = nil
    @action_type = 'Create Notice'
    @notice_html = params[:notice_html] ? params[:notice_html] : ''
    @notice_role_ids = params[:role] ? params[:role] : []
    @all_roles_selected_by_default = false

    unless ActionController::Base.helpers.strip_tags(@notice_html).gsub('&nbsp;', ' ').strip =~ /\S+/
      error = "Notice text is blank"
      @notice_html = '<p> </p>' #fix for IE 9
    end

    if @notice_role_ids.count == 0
      error = error ? error + "<br>No role is selected</br>" : "" +  "No role is selected"
    end

    @notice_role_ids.map!{|a| a.to_i }

    if error
      flash.now[:error] = error.html_safe
      respond_to do |format|
        format.html { render :action => "new" }
      end
      return
    end

    site_notice = Admin::SiteNotice.new
    site_notice.notice_html = @notice_html
    site_notice.created_by = current_visitor.id
    site_notice.updated_by = current_visitor.id
    site_notice.save!

    #storing all roles that should see this notice

    @notice_role_ids.each do |role_id|
      site_notice_role = Admin::SiteNoticeRole.new
      site_notice_role.notice_id = site_notice.id
      site_notice_role.role_id = role_id
      site_notice_role.save!
    end

    redirect_to admin_site_notices_path
  end

  def index
    #authorize Admin::SiteNotice
    #@all_notices = policy_scope(Admin::SiteNotice).order('updated_at desc')
    @all_notices = Admin::SiteNotice.order('updated_at desc')
    render json: @all_notices
  end

  def edit
    @action_type = 'Edit Notice'
    @all_roles_selected_by_default = false
    @notice = Admin::SiteNotice.find(params[:id])
    #authorize @notice
    @notice_html = @notice.notice_html
    fetch_notice_roles
    @notice_role_ids = @notice_roles.map{|notice_role| notice_role.role_id}
  end

  def update

    @action_type = 'Edit Notice'
    @all_roles_selected_by_default = false
    @notice = Admin::SiteNotice.find(params[:id])
    #authorize @notice
    fetch_notice_roles

    @notice_html = params[:notice_html]

    @notice_role_ids = params[:role].nil? ? [] : params[:role]
    @notice_role_ids.map! {|nr| nr.to_i}

    unless ActionController::Base.helpers.strip_tags(@notice_html).gsub('&nbsp;', ' ').strip =~ /\S+/
      error = "Notice text is blank"
      @notice_html = '<p> </p>' #fix for IE 9
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
    site_notice.updated_by = current_visitor.id
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
    notice_roles = fetch_notice_roles
    notice_roles.each do |notice_role|
      notice_role.destroy
    end

    notice_users = Admin::SiteNoticeUser.where(notice_id: params.fetch(:id))
    notice_users.each do |notice_user|
      notice_user.destroy
    end

    notice = Admin::SiteNotice.find(params.fetch(:id))
    #authorize notice, :destroy?
    notice.destroy

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
    # no authorization needed ...
    user_collapsed_notice = Admin::NoticeUserDisplayStatus.where(user_id: current_visitor.id).first_or_create
    status_to_be_set = (user_collapsed_notice.collapsed_status.nil? || user_collapsed_notice.collapsed_status == false)? true : false

    user_collapsed_notice.last_collapsed_at_time = DateTime.now
    user_collapsed_notice.collapsed_status = status_to_be_set
    user_collapsed_notice.save!
    if request.xhr?
      render :update do |page|
        status_to_be_set ? page << "$('oHideShowLink').setAttribute('title','Show Notices')" : page << "$('oHideShowLink').setAttribute('title','Hide Notices')"
      end
      return
    end
  end

  def dismiss_notice
    # no authorization needed ...
    notice = Admin::SiteNotice.find(params[:id])
    user_notice = Admin::SiteNoticeUser.where(notice_id: notice.id, user_id: current_visitor.id).first_or_create
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

  private

  def fetch_notice_roles
    @notice_roles = Admin::SiteNoticeRole.where(notice_id: params.fetch(:id))
  end

end
