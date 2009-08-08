require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/dataservice_bundle_contents/index.html.erb" do
  include Dataservice::BundleContentsHelper

  before(:each) do
    assigns[:dataservice_bundle_contents] = [
      stub_model(Dataservice::BundleContent,
        :body => "value for body"
      ),
      stub_model(Dataservice::BundleContent,
        :body => "value for body"
      )
    ]
  end

  it "renders a list of dataservice_bundle_contents" do
    render
    response.should have_tag("tr>td", "value for body".to_s, 2)
  end
end
