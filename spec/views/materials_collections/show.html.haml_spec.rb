require 'spec_helper'

describe "materials_collections/show" do
  before(:each) do

    @admin_user = Factory.next(:admin_user)
    controller.stub!(:current_user).and_return(@admin_user)
  end

  it "renders attributes in accordion (no materials)" do
    @materials_collection = assign(:materials_collection, FactoryGirl.create(:materials_collection))
    render

    assert_select ".list-item-wrapper .accordion_content .editable_block h4", :text => "Some name".to_s, :count => 1
    assert_select ".list-item-wrapper .accordion_content .editable_block p", :text => "Some description".to_s, :count => 1
    assert_select ".list-item-wrapper .accordion_content .editable_block .material_items p", :text => "No materials have been added to this collection.".to_s, :count => 1
  end

  it "renders attributes in accordion (with materials)" do
    @materials_collection = assign(:materials_collection, FactoryGirl.create(:materials_collection_with_items))
    render

    assert_select ".list-item-wrapper .accordion_content .editable_block h4", :text => "Some name".to_s, :count => 1
    assert_select ".list-item-wrapper .accordion_content .editable_block p", :text => "Some description".to_s, :count => 1
    assert_select ".list-item-wrapper .accordion_content .editable_block .material_items .material_item", :count => 5
  end
end
