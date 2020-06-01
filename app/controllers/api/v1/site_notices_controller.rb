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

  def get_notices_for_user
    notices_hash = Admin::SiteNotice.get_notices_for_user(current_visitor)
    @notice_display_type = notices_hash[:notice_display_type]
    @notices = notices_hash[:notices]
    render json: @notices
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

end
