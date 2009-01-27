require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/expectation_stems/show.html.erb" do
  include ExpectationStemsHelper
  
  before(:each) do
    assigns[:expectation_stem] = @expectation_stem = stub_model(ExpectationStem)
  end

  it "should render attributes in <p>" do
    render "/expectation_stems/show.html.erb"
  end
end

