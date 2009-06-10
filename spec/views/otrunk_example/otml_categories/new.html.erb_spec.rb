require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/otrunk_example_otml_categories/new.html.erb" do
  include OtrunkExample::OtmlCategoriesHelper
  
  before(:each) do
    assigns[:otml_category] = stub_model(OtrunkExample::OtmlCategory,
      :new_record? => true,
      :uuid => "value for uuid",
      :name => "value for name"
    )
  end

  it "renders new otml_category form" do
    render
    
    response.should have_tag("form[action=?][method=post]", otrunk_example_otml_categories_path) do
      with_tag("input#otml_category_uuid[name=?]", "otml_category[uuid]")
      with_tag("input#otml_category_name[name=?]", "otml_category[name]")
    end
  end
end


