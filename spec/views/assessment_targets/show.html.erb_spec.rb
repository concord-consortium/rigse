require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/assessment_targets/show.html.erb" do
  include AssessmentTargetsHelper
  
  before(:each) do
    assigns[:assessment_target] = @assessment_target = stub_model(AssessmentTarget)
  end

  it "should render attributes in <p>" do
    render "/assessment_targets/show.html.erb"
  end
end

