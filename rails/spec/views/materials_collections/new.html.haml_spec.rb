require 'spec_helper'

describe "materials_collections/new" do
  before(:each) do
    assign(:materials_collection, stub_model(MaterialsCollection,
      :name => "MyString",
      :description => "MyText",
      :project_id => 1
    ).as_new_record)

    @admin_user = FactoryBot.generate(:admin_user)
    allow(controller).to receive(:current_user).and_return(@admin_user)

    @projects = []
  end

  it "renders new materials_collection form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => materials_collections_path, :method => "post" do
      assert_select "input#materials_collection_name", :name => "materials_collection[name]"
      assert_select "textarea#materials_collection_description", :name => "materials_collection[description]"
    end
  end
end
