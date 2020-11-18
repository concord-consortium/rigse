class API::V1::SiteNoticesController < API::APIController

  before_filter :authorized

  # TODO: figure out why rspec is breaking and add authorization back (and remove before_filter)

  protected

  def authorized
    if current_visitor.has_role?('student') or !current_user
      raise Pundit::NotAuthorizedError
    end
  end

  public

  def index
    #authorize Admin::SiteNotice
    #@all_notices = policy_scope(Admin::SiteNotice).order('updated_at desc')
    @all_notices = Admin::SiteNotice.order('updated_at desc')
    render json: @all_notices
  end

  def create
    #authorize Admin::SiteNotice
    error = nil
    @action_type = 'Create Notice'
    @notice_html = params[:notice_html] ? params[:notice_html] : ''

    unless ActionController::Base.helpers.strip_tags(@notice_html).gsub('&nbsp;', ' ').strip =~ /\S+/
      error = "Notice text is blank"
      @notice_html = '<p> </p>' #fix for IE 9
    end

    if error
      redirect_to new_admin_site_notice_path, flash: {error: error.html_safe}
      return
    end

    site_notice = Admin::SiteNotice.new
    site_notice.notice_html = @notice_html
    site_notice.created_by = current_visitor.id
    site_notice.updated_by = current_visitor.id
    site_notice.save!

    redirect_to admin_site_notices_path
  end

  def update

    @action_type = 'Edit Notice'
    @notice = Admin::SiteNotice.find(params[:id])
    #authorize @notice

    @notice_html = params[:notice_html]

    unless ActionController::Base.helpers.strip_tags(@notice_html).gsub('&nbsp;', ' ').strip =~ /\S+/
      error = "Notice text is blank"
      @notice_html = '<p> </p>' #fix for IE 9
    end

    if error
      flash['error'] = error.html_safe
      respond_to do |format|
        format.html { render :action => "edit" }
      end
      return
    end

    site_notice = @notice
    site_notice.notice_html= @notice_html
    site_notice.updated_by = current_visitor.id
    site_notice.save!

    redirect_to admin_site_notices_path
  end

  def remove_notice
    #delete notice

    notice_users = Admin::SiteNoticeUser.where(notice_id: params.fetch(:id))
    notice_users.each do |notice_user|
      notice_user.destroy
    end

    notice = Admin::SiteNotice.find(params.fetch(:id))
    #authorize notice, :destroy?
    notice.destroy

    if request.xhr?
      render json: { notice_deleted: true }
      return
    end

    #redirect_to :action => 'index';
    #redirect_to admin_site_notices_path
  end

  def get_notices_for_user
    notices_hash = Admin::SiteNotice.get_notices_for_user(current_visitor)
    @notice_display = notices_hash[:notice_display]
    @notices = notices_hash[:notices]
    render json: { notices: @notices, notice_display: @notice_display }
  end

  def toggle_notice_display
    # no authorization needed ...
    user_collapsed_notice = Admin::NoticeUserDisplayStatus.where(user_id: current_visitor.id).first_or_create
    status_to_be_set = (user_collapsed_notice.collapsed_status.nil? || user_collapsed_notice.collapsed_status == false)? true : false

    user_collapsed_notice.last_collapsed_at_time = DateTime.now
    user_collapsed_notice.collapsed_status = status_to_be_set
    user_collapsed_notice.save!
    if request.xhr?
      render json: { notices_collapsed: status_to_be_set }
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
      render json: { notice_dismissed: true }
      return
    end
  end

  private

end
