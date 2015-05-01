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

  def server_running?
    begin
      open("http://localhost:#{$sunspot.port}/")
      true
    rescue Errno::ECONNREFUSED => e
      # server not running yet
      false
    rescue OpenURI::HTTPError
      # getting a response so the server is running
      true
    end
  end

  # TODO:  There might be a more eligent way of handling
  # this if we include some tips from this:
  # http://www.dzone.com/snippets/install-and-test-solrsunspot
  def solr_setup
    unless $sunspot
      ::WebMock.disable_net_connect!(:allow => ["localhost:8981","codeclimate.com"])
      $sunspot = Sunspot::Rails::Server.new

      pid = fork do
        STDERR.reopen('/dev/null')
        STDOUT.reopen('/dev/null')
        $sunspot.run
      end
      # shut down the Solr server
      at_exit { Process.kill('TERM', pid) }
      # wait for solr to start
      # wait for solr to start
      print "Waiting for Solr to start"
      until server_running?
        sleep 0.5
        print '.'
      end
      puts 'solr started'
    end

    Sunspot.session = $original_sunspot_session
  end
end
