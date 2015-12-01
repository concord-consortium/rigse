class API::V1::DashboardReportsController < API::APIController

  def report
    respond_to do |format|
      format.js do
        @offering = Portal::Offering.find(params[:offering_id], include:
        {
          learners: {student: :user}
        })
        toc = API::V1::DashboardReport.new(@offering)
        render :json => toc.to_hash, :callback => params[:callback]
      end
    end
  end

end
