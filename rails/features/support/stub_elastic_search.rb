# This can eventually be merged with stub_external_requests.rb when that is merged in

# stubs elasticsearch requests
Before do |scenario|
  WebMock.stub_request(:post, /#{ENV['ELASTICSEARCH_URL']}/).
  to_return(status: 200, body: "", headers: {})
end
