require 'spec_helper'

describe Dataservice::BlobsHelper do

  #Delete this example and add some real ones or delete this file
  it "is included in the helper object" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(Dataservice::BlobsHelper)
  end

  describe "blob_url_for(answer)" do
    it "should return a url for an answer" do
      blob = mock_model(Dataservice::Blob,
        :id => 10,
        :token => '9db05e66b61d11e08a75000c29231be6')
      answer = {}
      answer[:blob] = blob
      url = blob_url_for(answer)
      url.should match %r[dataservice/blobs/10.blob/9db05e66b61d11e08a75000c29231be6]
    end
  end

end
