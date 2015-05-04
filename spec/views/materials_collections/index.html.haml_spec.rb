require 'spec_helper'

describe "materials_collections/index" do
  before(:each) do

    collection1 = Factory.create(:materials_collection)
    collection2 = Factory.create(:materials_collection_with_items)

    assign(:materials_collections, MaterialsCollection.search(nil, nil, nil))

    @admin_user = Factory.next(:admin_user)
    controller.stub!(:current_user).and_return(@admin_user)
  end

  it "renders a list of materials_collections" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select ".list-item-wrapper .accordion_content .editable_block h4", :text => "Some name".to_s, :count => 2
    assert_select ".list-item-wrapper .accordion_content .editable_block p", :text => "Some description".to_s, :count => 2
    assert_select ".list-item-wrapper .accordion_content .editable_block .material_items p", :text => "No materials have been added to this collection.".to_s, :count => 1
    assert_select ".list-item-wrapper .accordion_content .editable_block .material_items .material_item", :count => 5
  end
end
