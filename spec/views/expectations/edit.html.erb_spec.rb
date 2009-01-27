require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/expectations/edit.html.erb" do
  include ExpectationsHelper
  
  before(:each) do
    assigns[:expectation] = @expectation = stub_model(Expectation,
      :new_record? => false
    )
  end

  it "should render edit form" do
    render "/expectations/edit.html.erb"
    
    response.should have_tag("form[action=#{expectation_path(@expectation)}][method=post]") do
    end
  end
end


