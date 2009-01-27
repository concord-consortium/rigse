require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/grade_span_expectations/edit.html.erb" do
  include GradeSpanExpectationsHelper
  
  before(:each) do
    assigns[:grade_span_expectation] = @grade_span_expectation = stub_model(GradeSpanExpectation,
      :new_record? => false
    )
  end

  it "should render edit form" do
    render "/grade_span_expectations/edit.html.erb"
    
    response.should have_tag("form[action=#{grade_span_expectation_path(@grade_span_expectation)}][method=post]") do
    end
  end
end


