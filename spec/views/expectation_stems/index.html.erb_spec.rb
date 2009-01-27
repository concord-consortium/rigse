require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/expectation_stems/index.html.erb" do
  include ExpectationStemsHelper
  
  before(:each) do
    assigns[:expectation_stems] = [
      stub_model(ExpectationStem),
      stub_model(ExpectationStem)
    ]
  end

  it "should render list of expectation_stems" do
    render "/expectation_stems/index.html.erb"
  end
end

