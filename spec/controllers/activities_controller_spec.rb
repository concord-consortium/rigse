
require File.expand_path('../../spec_helper', __FILE__)#include ApplicationHelper

failing_themes = {
  "xproject" => :itsi_su_specific_test
}

describe ActivitiesController do

  integrate_views

  before(:each) do
    @current_project = mock(
      :name => "test project",
      :using_custom_css? => false,
      :use_student_security_questions => false,
      :use_bitmap_snapshots? => false)
    Admin::Project.stub!(:default_project).and_return(@current_project)
    controller.stub(:before_render) {
      response.template.stub(:net_logo_package_name).and_return("blah")
      response.template.stub_chain(:current_project).and_return(@current_project);
    }

    @admin_user = Factory.create(:user, { :email => "test@test.com", :password => "password", :password_confirmation => "password" })
    @teacher = Factory.create(:portal_teacher)
    @teacher_user = @teacher.user
    @admin_user.add_role("admin")

    stub_current_user :admin_user

    @activity = Factory.create(:activity, {
      :name => "test activity",
      :description => "new decription"
    })

    Activity.stub!(:find).and_return([@activity])
    Activity.stub!(:published).and_return([@activity])
  end

  describe "index" do
    describe "for a teacher" do
      before(:each) do
        stub_current_user :teacher_user
      end

      describe "the project allows teacher editing" do
        before(:each) do
          @current_project.stub!(:teachers_can_author?).and_return(true)
        end
        it "should have a 'Create Activity' button" do
          fails_in_themes(failing_themes) do
            get :index
            assert_select("a[href=/activities/new]")
          end
        end
      end
      describe "the project does not allowteacher editing" do
        before(:each) do
          @current_project.stub!(:teachers_can_author?).and_return(false)
        end
        it "should not have a 'Create Activity' button" do
          fails_in_themes(failing_themes) do
            get :index
            assert_select("a[href=/activities/new]", 0)
          end
        end
      end
    end
  end

end
