require 'spec_helper'

describe "browse/external_activities/show" do
  let (:user) { Factory.create(:user) }
  let (:ext_act) { Factory.create(:external_activity, :url => 'http://activities.com', :description => '<p>desc foo bar</p><script>alert("evil!");</script>', :user => user) }
  let (:search_material) { Search::SearchMaterial.new(ext_act, user) }

  before(:each) do
    allow(view).to receive(:current_visitor).and_return(user)
    assigns[:search_material] = @search_material = search_material
  end

  it 'should present an external activity description' do
    render
    expect(rendered).to match /desc foo bar/
  end

  it 'should remove hazardous HTML tags from the description' do
    render
    expect(rendered).to match /<p>desc foo bar<\/p>/
    expect(rendered).not_to match /&lt;p&gt;desc foo bar&lt;\/p&gt;/
  end
end
