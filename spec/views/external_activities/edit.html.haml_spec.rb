require 'spec_helper'

describe "/external_activities/edit.html.haml" do
  let(:ext_act) { Factory.create(:external_activity, :url => 'http://activities.com') }

  before(:each) do
    assigns[:external_activity] = @external_activity = ext_act
    allow(view).to receive(:current_user).and_return(Factory.next(:admin_user))
  end

  it 'should have an is_official check box to designate official activities' do
    render
    assert_select("input[id=?]", 'external_activity_is_official')
  end

  it 'should not show the is_official check box to users without permissions' do
    allow(view).to receive(:current_user).and_return(Factory.next(:author_user))
    render
    assert_select "input[id=?]", 'external_activity_is_official', false
  end

  it 'should show the offical checkbox to project admins of the project material' do
    common_projects = [mock_model(Admin::Project, cohorts: [])]
    auth_user = Factory.next(:author_user)
    auth_user.stub(admin_for_projects: common_projects)
    ext_act.stub(projects: common_projects)
    allow(view).to receive(:current_user).and_return(auth_user)
    render
    assert_select "input[id=?]", 'external_activity_is_official'
  end

  include_examples 'projects listing'
end
