require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/grade_span_expectations/new.html.erb" do
  include GradeSpanExpectationsHelper
  
  before(:each) do
    assigns[:grade_span_expectation] = stub_model(GradeSpanExpectation,
      :new_record? => true
    )
  end

  it "should render new form" do
    render "/grade_span_expectations/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", grade_span_expectations_path) do
    end
  end
end


