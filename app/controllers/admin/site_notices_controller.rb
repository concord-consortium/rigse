class Admin::SiteNoticesController < ApplicationController

  before_filter :admin_or_manager, :except => [:toggle_notice_display, :dismiss_notice]

  # TODO: figure out why rspec is breaking and add authorization back (and remove before_filter)

  protected

  def admin_or_manager
    unless current_visitor.has_role?('admin') or current_visitor.has_role?('manager')
      raise Pundit::NotAuthorizedError
    end
  end

  public

  def new
    #authorize Admin::SiteNotice
    @action_type = 'Create Notice'
    @notice_role_ids = []
    @notice_html = '<p> </p>' #fix for IE 9
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

    redirect_to admin_site_notices_path
  end

  def index
    #authorize Admin::SiteNotice
    #@all_notices = policy_scope(Admin::SiteNotice).order('updated_at desc')
    @all_notices = Admin::SiteNotice.order('updated_at desc')
  end

  def edit
    @action_type = 'Edit Notice'
    @notice = Admin::SiteNotice.find(params[:id])
    #authorize @notice
    @notice_html = @notice.notice_html
  end

  def update

    @action_type = 'Edit Notice'
    @notice = Admin::SiteNotice.find(params[:id])
    #authorize @notice

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

end
