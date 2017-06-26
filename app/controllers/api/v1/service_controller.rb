
class API::V1::ServiceController < API::APIController

  def solr_initialized
    search = Sunspot.search([ExternalActivity])

    if ExternalActivity.count != search.total
      # FIXME: what about if there is a re-indexing job in process?
      # if the job itself re-checked if it was necessary to do the re-indexing
      # that would help a little bit. Especially if there is only one job worker.
      Delayed::Job.enqueue ReindexSolrJob.new
      message = "Re-indexing"
    else
      message = "Up to date"
    end

    render json: {message: message},
           status: 200
  end

end
