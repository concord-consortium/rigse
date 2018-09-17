require 'spec_helper'

describe "browse/external_activities/show" do
  let (:user) { FactoryBot.create(:user) }
  let (:ext_act) { FactoryBot.create(:external_activity, :url => 'http://activities.com', :long_description => '<p>desc foo bar</p><script>alert("evil!");</script>', :user => user) }
  let (:search_material) { Search::SearchMaterial.new(ext_act, user) }

  before(:each) do
    allow(view).to receive(:current_visitor).and_return(user)
    allow(view).to receive(:current_user).and_return(user)
    assigns[:search_material] = @search_material = search_material
  end

  it 'should present an external activity long description' do
    render
    expect(rendered).to match /desc foo bar/
  end

  it 'should remove hazardous HTML tags from the description' do
    render
    expect(rendered).to match /<p>desc foo bar<\/p>/
    expect(rendered).not_to match /&lt;p&gt;desc foo bar&lt;\/p&gt;/
  end
end
