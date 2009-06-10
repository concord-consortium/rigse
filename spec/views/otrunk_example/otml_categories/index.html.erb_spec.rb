require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/otrunk_example_otml_categories/index.html.erb" do
  include OtrunkExample::OtmlCategoriesHelper
  
  before(:each) do
    assigns[:otrunk_example_otml_categories] = [
      stub_model(OtrunkExample::OtmlCategory,
        :uuid => "value for uuid",
        :name => "value for name"
      ),
      stub_model(OtrunkExample::OtmlCategory,
        :uuid => "value for uuid",
        :name => "value for name"
      )
    ]
  end

  it "renders a list of otrunk_example_otml_categories" do
    render
    response.should have_tag("tr>td", "value for uuid".to_s, 2)
    response.should have_tag("tr>td", "value for name".to_s, 2)
  end
end

