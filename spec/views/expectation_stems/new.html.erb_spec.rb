require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/expectation_stems/new.html.erb" do
  include ExpectationStemsHelper
  
  before(:each) do
    assigns[:expectation_stem] = stub_model(ExpectationStem,
      :new_record? => true
    )
  end

  it "should render new form" do
    render "/expectation_stems/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", expectation_stems_path) do
    end
  end
end


