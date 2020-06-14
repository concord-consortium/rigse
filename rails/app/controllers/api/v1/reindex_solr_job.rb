require 'rake'

class API::V1::ReindexSolrJob

  # this is an approximation of whether the documents in Solr
  # match the number of activities in the database
  def self.is_up_to_date
    search = Sunspot.search([ExternalActivity])
    return ExternalActivity.count == search.total
  end

  def perform
    if ! self.class.is_up_to_date
      Rake::Task.clear
      RailsPortal::Application.load_tasks
      Rake::Task['sunspot:reindex'].invoke
    end
  end
end
