require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/portal_grades/edit.html.erb" do
  include Portal::GradesHelper

  before(:each) do
    assigns[:grade] = @grade = stub_model(Portal::Grade,
      :new_record? => false,
      :name => "value for name",
      :description => "value for description",
      :position => 1,
      :uuid => "value for uuid"
    )
  end

  it "renders the edit grade form" do
    pending "Broken example"
    render

    response.should have_tag("form[action=#{grade_path(@grade)}][method=post]") do
      with_tag('input#grade_name[name=?]', "grade[name]")
      with_tag('input#grade_description[name=?]', "grade[description]")
      with_tag('input#grade_position[name=?]', "grade[position]")
      with_tag('input#grade_uuid[name=?]', "grade[uuid]")
    end
  end
end
