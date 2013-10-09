require File.expand_path('../../spec_helper', __FILE__)#include ApplicationHelper

describe ActivitiesController do
  before(:each) do
    @current_project = mock(
      :name => "test project",
      :using_custom_css? => false,
      :use_student_security_questions => false,
      :use_bitmap_snapshots? => false,
      :require_user_consent? => false)
    Admin::Project.stub!(:default_project).and_return(@current_project)
    controller.stub(:before_render) {
      response.template.stub(:net_logo_package_name).and_return("blah")
      response.template.stub_chain(:current_project).and_return(@current_project);
    }

    @admin_user = login_admin

    @activity = Factory.create(:activity, {
      :name => "test activity",
      :description => "new decription",
      :publication_status => "published"
    })
  end

  describe '#index' do
    context 'when the user is an author' do
      before(:each) do
        current_visitor = login_author
      end

      it 'shows only public, official, and user-owned activities' do
        # TODO: have more than one activity so there are activities which get filtered out of the return here
        get :index
        assigns[:activities].length.should be(Activity.published.count + Activity.by_user(current_visitor).count)
      end
    end

    context 'when the user is an admin' do
      it 'shows all activities' do
        get :index
        assigns[:activities].length.should be(Activity.count)
      end

      it 'filters activities by keyword when provided' do
        get :index, {:name => 'filtered'}
        assigns[:activities].length.should be(1)
      end

      it 'shows drafts when box is checked' do
        pending "Is this box visible to authors (not just admins)? If not, does it do anything?"
      end
    end
  end

  describe "#show" do
    describe "with teacher mode='true'" do
      before(:each) do
        controller.stub!(:render)
        get :show, :id => @activity.id, :teacher_mode => "true"
      end
      it "should assign true to teacher_mode instance var" do
        assert (assigns(:teacher_mode) == true)
      end
    end
    describe "with teacher mode='false'" do
      before(:each) do
        controller.stub!(:render)
        get :show, :id => @activity.id, :teacher_mode => "false"
      end
      it "should assign true to teacher_mode instance var" do
        assert (assigns(:teacher_mode) == false)
      end
    end
  end
end
