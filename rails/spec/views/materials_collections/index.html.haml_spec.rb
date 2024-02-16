require 'spec_helper'

describe "materials_collections/index" do
  before(:each) do
    project = FactoryBot.create(:project, name: "Some Project")
    collection1 = FactoryBot.create(:materials_collection, project: project)
    collection2 = FactoryBot.create(:materials_collection_with_items, project: project)

    assign(:materials_collections, MaterialsCollection.search(nil, nil, nil))

    @admin_user = FactoryBot.generate(:admin_user)
    allow(controller).to receive(:current_user).and_return(@admin_user)

    @projects = []
  end

  it "renders a list of materials_collections" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select ".list-item-wrapper h3", :text => "Some Project: Some name".to_s, :count => 2
    assert_select ".list-item-wrapper p", :text => "Some description".to_s, :count => 2
  end
end
