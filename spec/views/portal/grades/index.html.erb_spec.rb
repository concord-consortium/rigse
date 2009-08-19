require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/portal_grades/index.html.erb" do
  include Portal::GradesHelper

  before(:each) do
    assigns[:portal_grades] = [
      stub_model(Portal::Grade,
        :name => "value for name",
        :description => "value for description",
        :position => 1,
        :uuid => "value for uuid"
      ),
      stub_model(Portal::Grade,
        :name => "value for name",
        :description => "value for description",
        :position => 1,
        :uuid => "value for uuid"
      )
    ]
  end

  it "renders a list of portal_grades" do
    render
    response.should have_tag("tr>td", "value for name".to_s, 2)
    response.should have_tag("tr>td", "value for description".to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", "value for uuid".to_s, 2)
  end
end
