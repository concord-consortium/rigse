require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/dataservice_bundle_contents/show.html.erb" do
  include Dataservice::BundleContentsHelper
  before(:each) do
    assigns[:bundle_content] = @bundle_content = stub_model(Dataservice::BundleContent,
      :body => "value for body"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ body/)
  end
end
