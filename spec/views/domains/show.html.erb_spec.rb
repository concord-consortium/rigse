require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/domains/show.html.erb" do
  include DomainsHelper
  
  before(:each) do
    assigns[:domain] = @domain = stub_model(Domain)
  end

  it "should render attributes in <p>" do
    render "/domains/show.html.erb"
  end
end

