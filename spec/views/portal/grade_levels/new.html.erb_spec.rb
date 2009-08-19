require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/portal_grade_levels/new.html.erb" do
  include Portal::GradeLevelsHelper

  before(:each) do
    assigns[:grade_level] = stub_model(Portal::GradeLevel,
      :new_record? => true,
      :has_grade_levels_id => 1,
      :has_grade_levels_type => "value for has_grade_levels_type",
      :grade_id => 1,
      :uuid => "value for uuid"
    )
  end

  it "renders new grade_level form" do
    render

    response.should have_tag("form[action=?][method=post]", portal_grade_levels_path) do
      with_tag("input#grade_level_has_grade_levels_id[name=?]", "grade_level[has_grade_levels_id]")
      with_tag("input#grade_level_has_grade_levels_type[name=?]", "grade_level[has_grade_levels_type]")
      with_tag("input#grade_level_grade_id[name=?]", "grade_level[grade_id]")
      with_tag("input#grade_level_uuid[name=?]", "grade_level[uuid]")
    end
  end
end
