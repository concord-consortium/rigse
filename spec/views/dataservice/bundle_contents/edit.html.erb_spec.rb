require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/dataservice_bundle_contents/edit.html.erb" do
  include Dataservice::BundleContentsHelper

  before(:each) do
    assigns[:bundle_content] = @bundle_content = stub_model(Dataservice::BundleContent,
      :new_record? => false,
      :body => "value for body"
    )
  end

  it "renders the edit bundle_content form" do
    render

    response.should have_tag("form[action=#{bundle_content_path(@bundle_content)}][method=post]") do
      with_tag('textarea#bundle_content_body[name=?]', "bundle_content[body]")
    end
  end
end
