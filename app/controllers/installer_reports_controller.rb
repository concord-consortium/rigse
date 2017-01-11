class InstallerReportsController < ApplicationController
  def index
    authorize InstallerReport
    if params[:search]
      @installer_reports = policy_scope(InstallerReport).search(params[:search], params[:page], nil)
    else
      # by default just show reports for sessions that have access_counts > 1
      @installer_reports = policy_scope(InstallerReport).joins(:jnlp_session).
        where("dataservice_jnlp_sessions.access_count > 1").paginate(:per_page => 20, :page => params[:page])
    end
  end
end
