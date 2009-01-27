require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/assessment_targets/edit.html.erb" do
  include AssessmentTargetsHelper
  
  before(:each) do
    assigns[:assessment_target] = @assessment_target = stub_model(AssessmentTarget,
      :new_record? => false
    )
  end

  it "should render edit form" do
    render "/assessment_targets/edit.html.erb"
    
    response.should have_tag("form[action=#{assessment_target_path(@assessment_target)}][method=post]") do
    end
  end
end


