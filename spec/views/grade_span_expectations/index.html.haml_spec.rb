require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/grade_span_expectations/index.html.haml" do
  
  before(:each) do
    assigns[:grade_span_expectations] = [
      stub_model(GradeSpanExpectation),
      stub_model(GradeSpanExpectation)
    ]
  end

  it "should render list of grade_span_expectations" do
    pending "Broken example"
    render "/grade_span_expectations/index.html.haml"
  end
end

