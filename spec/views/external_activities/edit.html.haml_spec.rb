require 'spec_helper'

describe "/external_activities/edit.html.haml" do
  let(:ext_act) { Factory.create(:external_activity, :url => 'http://activities.com') }

  before(:each) do
    assigns[:external_activity] = @external_activity = ext_act
    view.stub!(:current_visitor).and_return(Factory.next(:researcher_user))
    view.stub!(:current_user).and_return(Factory.next(:researcher_user))
  end

  it 'should have an is_official check box to designate official activities' do
    render
    assert_select("input[id=?]", 'external_activity_is_official')
  end

  it 'should not show the is_official check box to users without permissions' do
    view.stub!(:current_visitor).and_return(Factory.next(:author_user))
    render
    assert_select "input[id=?]", 'external_activity_is_official', false
  end

  include_examples 'projects listing'
end
