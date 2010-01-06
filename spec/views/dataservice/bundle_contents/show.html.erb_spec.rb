require 'spec_helper'

describe "/dataservice_bundle_contents/show.html.erb" do
  include Dataservice::BundleContentsHelper
  before(:each) do
    assigns[:bundle_content] = @bundle_content = stub_model(Dataservice::BundleContent,
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
  end

  it "renders attributes in <p>" do
    pending "Broken example"
    render
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/value\ for\ body/)
    response.should have_text(/value\ for\ otml/)
    response.should have_text(/false/)
    response.should have_text(/false/)
    response.should have_text(/false/)
    response.should have_text(/value\ for\ uuid/)
  end
end
