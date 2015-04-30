require 'spec_helper'

describe "materials_collections/edit" do
  before(:each) do
    @materials_collection = assign(:materials_collection, stub_model(MaterialsCollection,
      :name => "MyString",
      :description => "MyText",
      :project_id => 1
    ))

    @admin_user = Factory.next(:admin_user)
    controller.stub!(:current_user).and_return(@admin_user)
  end

  it "renders the edit materials_collection form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => materials_collections_path(@materials_collection), :method => "post" do
      assert_select "input#materials_collection_name", :name => "materials_collection[name]"
      assert_select "textarea#materials_collection_description", :name => "materials_collection[description]"
    end
  end
end
