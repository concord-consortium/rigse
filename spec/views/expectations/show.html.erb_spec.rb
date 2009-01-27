require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/expectations/show.html.erb" do
  include ExpectationsHelper
  
  before(:each) do
    assigns[:expectation] = @expectation = stub_model(Expectation)
  end

  it "should render attributes in <p>" do
    render "/expectations/show.html.erb"
  end
end

