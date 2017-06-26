require 'rake'

class API::V1::ReindexSolrJob
  def perform
    # This needs to be in a background job
    Rake::Task.clear
    RailsPortal::Application.load_tasks
    Rake::Task['sunspot:reindex'].invoke
  end
end
