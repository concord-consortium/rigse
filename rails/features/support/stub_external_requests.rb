# stubs aws-sdk requests
WebMock.stub_request(:get, /http:\/\/169\.254\.169\.254\//).
  with(
    headers: {
	  'Accept'=>'*/*',
	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
	  'Host'=>'169.254.169.254',
	  'User-Agent'=>'Ruby'
    }).
  to_return(status: 200, body: "", headers: {})

# stub google requests
WebMock.stub_request(:get, /http:\/\/metadata\.google\.internal\//).
  with(
    headers: {
	  'Accept'=>'*/*',
	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
	  'Host'=>'metadata.google.internal',
	  'Metadata-Flavor'=>'Google',
	  'User-Agent'=>'Ruby'
    }).
  to_return(status: 200, body: "", headers: {})
