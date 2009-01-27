require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/grade_span_expectations/index.html.erb" do
  include GradeSpanExpectationsHelper
  
  before(:each) do
    assigns[:grade_span_expectations] = [
      stub_model(GradeSpanExpectation),
      stub_model(GradeSpanExpectation)
    ]
  end

  it "should render list of grade_span_expectations" do
    render "/grade_span_expectations/index.html.erb"
  end
end

