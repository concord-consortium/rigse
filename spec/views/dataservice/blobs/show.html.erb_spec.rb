require 'spec_helper'

describe "/dataservice_blobs/show.html.erb" do
  include Dataservice::BlobsHelper
  before(:each) do
    assigns[:blob] = @blob = stub_model(Dataservice::Blob)
  end

  it "renders attributes in <p>" do
    render
  end
end
