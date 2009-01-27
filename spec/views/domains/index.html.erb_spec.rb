require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/domains/index.html.erb" do
  include DomainsHelper
  
  before(:each) do
    assigns[:domains] = [
      stub_model(Domain),
      stub_model(Domain)
    ]
  end

  it "should render list of domains" do
    render "/domains/index.html.erb"
  end
end

