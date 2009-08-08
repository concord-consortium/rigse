require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/portal_schools/index.html.erb" do
  include Portal::SchoolsHelper

  before(:each) do
    assigns[:portal_schools] = [
      stub_model(Portal::School,
        :district_id => 1,
        :nces_school_id => 1,
        :name => "value for name",
        :description => "value for description",
        :uuid => "value for uuid"
      ),
      stub_model(Portal::School,
        :district_id => 1,
        :nces_school_id => 1,
        :name => "value for name",
        :description => "value for description",
        :uuid => "value for uuid"
      )
    ]
  end

  it "renders a list of portal_schools" do
    render
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", "value for name".to_s, 2)
    response.should have_tag("tr>td", "value for description".to_s, 2)
    response.should have_tag("tr>td", "value for uuid".to_s, 2)
  end
end
