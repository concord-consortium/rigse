require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/portal_grade_levels/index.html.erb" do
  include Portal::GradeLevelsHelper

  before(:each) do
    assigns[:portal_grade_levels] = [
      stub_model(Portal::GradeLevel,
        :has_grade_levels_id => 1,
        :has_grade_levels_type => "value for has_grade_levels_type",
        :grade_id => 1,
        :uuid => "value for uuid"
      ),
      stub_model(Portal::GradeLevel,
        :has_grade_levels_id => 1,
        :has_grade_levels_type => "value for has_grade_levels_type",
        :grade_id => 1,
        :uuid => "value for uuid"
      )
    ]
  end

  it "renders a list of portal_grade_levels" do
    pending "Broken example"
    render
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", "value for has_grade_levels_type".to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", "value for uuid".to_s, 2)
  end
end
