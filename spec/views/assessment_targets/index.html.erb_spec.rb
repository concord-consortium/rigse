require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/assessment_targets/index.html.erb" do
  include AssessmentTargetsHelper
  
  before(:each) do
    assigns[:assessment_targets] = [
      stub_model(AssessmentTarget),
      stub_model(AssessmentTarget)
    ]
  end

  it "should render list of assessment_targets" do
    render "/assessment_targets/index.html.erb"
  end
end

