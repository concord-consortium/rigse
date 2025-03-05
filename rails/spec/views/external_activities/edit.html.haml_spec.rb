require 'spec_helper'

describe "/external_activities/edit.html.haml" do
  let(:ext_act) { FactoryBot.create(:external_activity, :url => 'http://activities.com') }

  before(:each) do
    # RAILS-UPGRADE-TODO: Find out why the next line is needed for these tests to pass. Since the upgrade from Rails v6.1 to 7.0
    # the tests will fail without it. It has something to do with the partials rendered in the view. Rails
    # can't seem to find the partial files without specifying the subdirectory in app/views here.
    view.lookup_context.prefixes << "external_activities"
    assigns[:external_activity] = @external_activity = ext_act
    allow(view).to receive(:current_user).and_return(FactoryBot.generate(:admin_user))
  end

  it 'should have an is_official check box to designate official activities' do
    render
    assert_select("input[id=?]", 'external_activity_is_official')
  end

  it 'should not show the is_official check box to users without permissions' do
    allow(view).to receive(:current_user).and_return(FactoryBot.generate(:author_user))
    render
    assert_select "input[id=?]", 'external_activity_is_official', false
  end

  it 'should not show the offical checkbox to project admins of the project material' do
    common_projects = [mock_model(Admin::Project, cohorts: [])]
    auth_user = FactoryBot.generate(:author_user)
    allow(auth_user).to receive_messages(is_project_admin?: true)
    allow(ext_act).to receive_messages(projects: common_projects)
    allow(view).to receive(:current_user).and_return(auth_user)
    render
    assert_select "input[id=?]", 'external_activity_is_official', false
  end

  include_examples 'projects listing'
end
