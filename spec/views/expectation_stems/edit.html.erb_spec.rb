require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/expectation_stems/edit.html.erb" do
  include ExpectationStemsHelper
  
  before(:each) do
    assigns[:expectation_stem] = @expectation_stem = stub_model(ExpectationStem,
      :new_record? => false
    )
  end

  it "should render edit form" do
    render "/expectation_stems/edit.html.erb"
    
    response.should have_tag("form[action=#{expectation_stem_path(@expectation_stem)}][method=post]") do
    end
  end
end


