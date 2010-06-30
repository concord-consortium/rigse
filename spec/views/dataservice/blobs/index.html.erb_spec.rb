require 'spec_helper'

describe "/dataservice_blobs/index.html.erb" do
  include Dataservice::BlobsHelper

  before(:each) do
    assigns[:dataservice_blobs] = [
      stub_model(Dataservice::Blob),
      stub_model(Dataservice::Blob)
    ]
  end

  it "renders a list of dataservice_blobs" do
    render
  end
end
