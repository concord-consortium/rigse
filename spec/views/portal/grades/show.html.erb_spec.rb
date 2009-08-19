require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/portal_grades/show.html.erb" do
  include Portal::GradesHelper
  before(:each) do
    assigns[:grade] = @grade = stub_model(Portal::Grade,
      :name => "value for name",
      :description => "value for description",
      :position => 1,
      :uuid => "value for uuid"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ name/)
    response.should have_text(/value\ for\ description/)
    response.should have_text(/1/)
    response.should have_text(/value\ for\ uuid/)
  end
end
