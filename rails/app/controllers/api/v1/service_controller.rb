
class API::V1::ServiceController < API::APIController

  def solr_initialized
    if API::V1::ReindexSolrJob.is_up_to_date
      message = "Up to date"
    else
      API::V1::ReindexSolrJob.perform_later
      message = "Re-indexing"
    end

    render json: {message: message},
           status: 200
  end

end
