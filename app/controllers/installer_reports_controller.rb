class InstallerReportsController < ApplicationController
  include RestrictedController
  # PUNDIT_CHECK_FILTERS
  before_filter :admin_only

  def index
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    authorize InstallerReport
    if params[:search]
      @installer_reports = InstallerReport.search(params[:search], params[:page], nil)
    # PUNDIT_REVIEW_SCOPE
    # PUNDIT_CHECK_SCOPE (found instance)
    @installer_reports = policy_scope(InstallerReport)
    else
      # by default just show reports for sessions that have access_counts > 1
      @installer_reports = InstallerReport.joins(:jnlp_session).
        where("dataservice_jnlp_sessions.access_count > 1").paginate(:per_page => 20, :page => params[:page])
    end
  end
end
