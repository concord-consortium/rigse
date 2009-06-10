require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/otrunk_example_otml_categories/show.html.erb" do
  include OtrunkExample::OtmlCategoriesHelper
  before(:each) do
    assigns[:otml_category] = @otml_category = stub_model(OtrunkExample::OtmlCategory,
      :uuid => "value for uuid",
      :name => "value for name"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ uuid/)
    response.should have_text(/value\ for\ name/)
  end
end

