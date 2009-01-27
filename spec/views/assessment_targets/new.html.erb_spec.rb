require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/assessment_targets/new.html.erb" do
  include AssessmentTargetsHelper
  
  before(:each) do
    assigns[:assessment_target] = stub_model(AssessmentTarget,
      :new_record? => true
    )
  end

  it "should render new form" do
    render "/assessment_targets/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", assessment_targets_path) do
    end
  end
end


