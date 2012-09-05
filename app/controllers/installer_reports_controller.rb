class InstallerReportsController < ApplicationController
  include RestrictedController
  before_filter :admin_only

  def index
    if params[:search]
      @installer_reports = InstallerReport.search(params[:search], params[:page], nil)
    else
      # by default just show reports for sessions that have access_counts > 1
      @installer_reports = InstallerReport.joins(:jnlp_session).
        where("dataservice_jnlp_sessions.access_count > 1").paginate(:per_page => 20, :page => params[:page])
    end
  end
end