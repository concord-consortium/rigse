require 'spec_helper'

describe "/dataservice_blobs/new.html.erb" do
  include Dataservice::BlobsHelper

  before(:each) do
    assigns[:blob] = stub_model(Dataservice::Blob,
      :new_record? => true
    )
  end

  it "renders new blob form" do
    render

    response.should have_tag("form[action=?][method=post]", dataservice_blobs_path) do
    end
  end
end
