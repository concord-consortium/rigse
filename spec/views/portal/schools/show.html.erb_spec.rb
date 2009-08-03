require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/portal_schools/show.html.erb" do
  include Portal::SchoolsHelper
  before(:each) do
    assigns[:school] = @school = stub_model(Portal::School,
      :district_id => 1,
      :nces_school_id => 1,
      :name => "value for name",
      :description => "value for description",
      :uuid => "value for uuid"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/value\ for\ name/)
    response.should have_text(/value\ for\ description/)
    response.should have_text(/value\ for\ uuid/)
  end
end
