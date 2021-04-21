class Admin::SiteNoticesController < ApplicationController

  before_action :admin_or_manager, :except => [:toggle_notice_display, :dismiss_notice]

  # TODO: figure out why rspec is breaking and add authorization back (and remove before_action)

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

end
