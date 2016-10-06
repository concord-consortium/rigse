$original_sunspot_session = Sunspot.session
Sunspot.session = Sunspot::Rails::StubSessionProxy.new($original_sunspot_session)

module SolrSpecHelper

  def clean_solar_index
    Search::SearchableModels.each do |model_type|
      model_type.remove_all_from_index!
    end
  end

  def reindex_all
    Search::SearchableModels.each do |m|
      m.reindex
      Sunspot.commit
    end
  end

  def test_solr_server
    open("http://localhost:#{$sunspot.port}/")
  end

  def solr_setup
    unless $sunspot
      ::WebMock.disable_net_connect!(:allow => ["localhost:8981", "codeclimate.com"])
      $sunspot = Sunspot::Rails::Server.new
      begin
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
