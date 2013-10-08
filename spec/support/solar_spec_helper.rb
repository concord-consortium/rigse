$original_sunspot_session = Sunspot.session
Sunspot.session = Sunspot::Rails::StubSessionProxy.new($original_sunspot_session)

module SolrSpecHelper

  def clean_solar_index
    Search::AllMaterials.each do |model_type|
      model_type.remove_all_from_index!
    end
  end

  def solr_setup
    unless $sunspot
      $sunspot = Sunspot::Rails::Server.new

      pid = fork do
        STDERR.reopen('/dev/null')
        STDOUT.reopen('/dev/null')
        $sunspot.run
      end
      # shut down the Solr server
      at_exit { Process.kill('TERM', pid) }
      # wait for solr to start
      sleep 5
      ::WebMock.disable_net_connect!(:allow => ["localhost:8981"])
    end

    Sunspot.session = $original_sunspot_session
  end
end