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

    @admin_user = Factory.create(:user, { :email => "test@test.com", :password => "password", :password_confirmation => "password" })
    @admin_user.add_role("admin")

    stub_current_user :admin_user
    
    @activity = Factory.create(:activity, {
      :name => "test activity",
      :description => "new decription",
      :publication_status => "published"
    })
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
