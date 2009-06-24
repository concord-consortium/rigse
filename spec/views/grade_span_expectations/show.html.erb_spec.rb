require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/grade_span_expectations/show.html.erb" do
  
  before(:each) do
    assigns[:grade_span_expectation] = @grade_span_expectation = stub_model(GradeSpanExpectation)
  end

  it "should render attributes in <p>" do
    render "/grade_span_expectations/show.html.erb"
  end
end

