require 'spec_helper'

describe "/dataservice/blobs/index.html.haml" do
  include Dataservice::BlobsHelper

  before(:each) do
    generate_default_project_and_jnlps_with_factories
    logout_user
    login_admin
    collection = WillPaginate::Collection.create(1,10) do |coll|
      coll << stub_model(Dataservice::Blob, :id => 1, :token => "8ad04a50ba96463d80407cd119173b86", :content => "1")
      coll << stub_model(Dataservice::Blob, :id => 2, :token => "8ad04a50ba96463d80407cd119173b86", :content => "2")
      coll.total_entries = 2
    end
    assigns[:dataservice_blobs] = collection
  end

  it "renders a list of dataservice_blobs" do
    render
  end
end
