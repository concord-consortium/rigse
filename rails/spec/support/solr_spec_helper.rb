require 'open-uri'

$original_sunspot_session = Sunspot.session
Sunspot.session = Sunspot::Rails::StubSessionProxy.new($original_sunspot_session)

module SolrSpecHelper

  SOLR_HOST = ENV.fetch('TEST_SOLR_HOST', 'localhost')
  SOLR_PORT = ENV.fetch('TEST_SOLR_PORT', 8981)

  def clean_solar_index
    Search::AllSearchableModels.each do |model_type|
      model_type.remove_all_from_index!
    end
  end

  def reindex_all
    Search::AllSearchableModels.each do |m|
      m.reindex
      Sunspot.commit
    end
  end

  def test_solr_server
    URI.open("http://#{SOLR_HOST}:#{SOLR_PORT}/")
  end

  def solr_setup
    unless $sunspot
      begin

        $sunspot = Sunspot::Rails::Server.new

        test_solr_server

      rescue Errno::ECONNREFUSED
        puts 'SOLR server is not running. Start it using:'
        puts 'RAILS_ENV=test rake sunspot:solr:run'
        raise 'SOLR server is not running'
      rescue OpenURI::HTTPError => e
        puts 'SOLR server returns an error. It is possible that it is still initializing (e.g. loading cores)'
        puts 'and you need to wait a bit more before running the tests.'
        # Re-raise exception so it's visible why it failed.
        raise e
      end
    end
    Sunspot.session = $original_sunspot_session
  end
end
