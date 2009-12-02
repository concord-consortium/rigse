require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/portal_grade_levels/show.html.erb" do
  include Portal::GradeLevelsHelper
  before(:each) do
    assigns[:grade_level] = @grade_level = stub_model(Portal::GradeLevel,
      :has_grade_levels_id => 1,
      :has_grade_levels_type => "value for has_grade_levels_type",
      :grade_id => 1,
      :uuid => "value for uuid"
    )
  end

  it "renders attributes in <p>" do
    pending "Broken example"
    render
    response.should have_text(/1/)
    response.should have_text(/value\ for\ has_grade_levels_type/)
    response.should have_text(/1/)
    response.should have_text(/value\ for\ uuid/)
  end
end
