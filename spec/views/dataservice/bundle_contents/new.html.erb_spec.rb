require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/dataservice_bundle_contents/new.html.erb" do
  include Dataservice::BundleContentsHelper

  before(:each) do
    assigns[:bundle_content] = stub_model(Dataservice::BundleContent,
      :new_record? => true,
      :body => "value for body"
    )
  end

  it "renders new bundle_content form" do
    render

    response.should have_tag("form[action=?][method=post]", dataservice_bundle_contents_path) do
      with_tag("textarea#bundle_content_body[name=?]", "bundle_content[body]")
    end
  end
end
