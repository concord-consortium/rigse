require 'spec_helper'

describe "/dataservice_bundle_contents/index.html.erb" do
  include Dataservice::BundleContentsHelper

  before(:each) do
    assigns[:dataservice_bundle_contents] = [
      stub_model(Dataservice::BundleContent,
        :id => 1,
        :bundle_logger_id => 1,
        :position => 1,
        :body => "value for body",
        :otml => "value for otml",
        :processed => false,
        :valid_xml => false,
        :empty => false,
        :uuid => "value for uuid"
      ),
      stub_model(Dataservice::BundleContent,
        :id => 1,
        :bundle_logger_id => 1,
        :position => 1,
        :body => "value for body",
        :otml => "value for otml",
        :processed => false,
        :valid_xml => false,
        :empty => false,
        :uuid => "value for uuid"
      )
    ]
  end

  it "renders a list of dataservice_bundle_contents" do
    pending "Broken example"
    render
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", "value for body".to_s, 2)
    response.should have_tag("tr>td", "value for otml".to_s, 2)
    response.should have_tag("tr>td", false.to_s, 2)
    response.should have_tag("tr>td", false.to_s, 2)
    response.should have_tag("tr>td", false.to_s, 2)
    response.should have_tag("tr>td", "value for uuid".to_s, 2)
  end
end
