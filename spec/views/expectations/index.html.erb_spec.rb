require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/expectations/index.html.erb" do
  include ExpectationsHelper
  
  before(:each) do
    assigns[:expectations] = [
      stub_model(Expectation),
      stub_model(Expectation)
    ]
  end

  it "should render list of expectations" do
    render "/expectations/index.html.erb"
  end
end

