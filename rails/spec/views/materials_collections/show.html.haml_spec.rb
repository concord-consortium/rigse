require 'spec_helper'

describe "materials_collections/show" do
  before(:each) do

    @admin_user = FactoryBot.generate(:admin_user)
    allow(controller).to receive(:current_user).and_return(@admin_user)
  end

  it "renders attributes in accordion (no materials)" do
    project = FactoryBot.create(:project, name: "Some Project", landing_page_slug: "some-project")
    assign(:materials_collection,
      FactoryBot.create(:materials_collection, project: project))
    render

    assert_select ".list-item-wrapper h3", :text => "Some Project: Some name".to_s, :count => 1
    assert_select ".list-item-wrapper p", :text => "Some description".to_s, :count => 1
  end

end
