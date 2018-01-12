require 'webmock/cucumber'

# capybara needs to make a connection to the rails app that it starts up
# when doing the javascript scenarios. I tried making this conditional
# on the javascript scenarios, but there were still cases of cleanup that
# failed when scenarios alternated between javascript and not

solr_host = ENV['TEST_SOLR_HOST'] || 'localhost'
solr_port = ENV['TEST_SOLR_PORT'] || 8981

WebMock.disable_net_connect!(   :allow_localhost => true, 
                                :allow => [ "#{solr_host}:#{solr_port}",
                                            "codeclimate.com" ] 
                            )
