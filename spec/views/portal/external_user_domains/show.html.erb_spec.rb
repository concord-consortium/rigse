require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/portal_external_user_domains/show.html.erb" do
  include Portal::ExternalUserDomainsHelper
  before(:each) do
    assigns[:external_user_domain] = @external_user_domain = stub_model(Portal::ExternalUserDomain,
      :name => "value for name",
      :description => "value for description",
      :server_url => "value for server_url",
      :uuid => "value for uuid"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ name/)
    response.should have_text(/value\ for\ description/)
    response.should have_text(/value\ for\ server_url/)
    response.should have_text(/value\ for\ uuid/)
  end
end
