require 'spec_helper'

describe "/dataservice/blobs/show.html.haml" do
  include Dataservice::BlobsHelper
  before(:each) do
    generate_default_project_and_jnlps_with_factories
    logout_user
    login_admin
    assigns[:dataservice_blob] = @dataservice_blob = stub_model(Dataservice::Blob, :id => 1, :token => "8ad04a50ba96463d80407cd119173b86", :content => "")
  end

  it "renders attributes in <p>" do
    render
  end
end
