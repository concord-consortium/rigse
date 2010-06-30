require 'spec_helper'

describe "/dataservice_blobs/edit.html.erb" do
  include Dataservice::BlobsHelper

  before(:each) do
    assigns[:blob] = @blob = stub_model(Dataservice::Blob,
      :new_record? => false
    )
  end

  it "renders the edit blob form" do
    render

    response.should have_tag("form[action=#{blob_path(@blob)}][method=post]") do
    end
  end
end
