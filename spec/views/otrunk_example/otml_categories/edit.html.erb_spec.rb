require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/otrunk_example_otml_categories/edit.html.erb" do
  include OtrunkExample::OtmlCategoriesHelper
  
  before(:each) do
    assigns[:otml_category] = @otml_category = stub_model(OtrunkExample::OtmlCategory,
      :new_record? => false,
      :uuid => "value for uuid",
      :name => "value for name"
    )
  end

  it "renders the edit otml_category form" do
    render
    
    response.should have_tag("form[action=#{otml_category_path(@otml_category)}][method=post]") do
      with_tag('input#otml_category_uuid[name=?]', "otml_category[uuid]")
      with_tag('input#otml_category_name[name=?]', "otml_category[name]")
    end
  end
end


