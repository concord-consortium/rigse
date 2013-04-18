require File.expand_path('../../spec_helper', __FILE__)#include ApplicationHelper

describe InvestigationsController do
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

    login_admin
    
    @investigation = Factory.create(:investigation, {
      :name => "test investigation",
      :description => "new decription",
      :publication_status => "published"
    })
  end

  it "should handle the show method without error" do
    get :show, :id => @investigation.id
  end
  
  it "should handle the duplicate metod without error" do
    get :duplicate, :id => @investigation.id
  end
  
  describe "Researcher Reports" do
    before(:each) do
      controller.should_receive(:send_data) { | data, options | 
        options[:type].should == "application/vnd.ms.excel"
      }
      # this is needed to prevent a missing template call, the real send_data method
      # keeps rails from doing an implicit render, but since we are stubing send_data here
      # the implicit render isn't stopped
      controller.stub!(:render)
    end
    
    it 'should return an XLS file for the global Usage Report' do
      get :usage_report
    end

    it 'should return an XLS file for the global Details Report' do
      get :details_report
    end

    it 'should return an XLS file for the specific Usage Report' do
      get :usage_report, :id => @investigation.id
    end

    it 'should return an XLS file for the specific Details Report' do
      get :details_report, :id => @investigation.id
    end
  end

  describe "#show" do
    describe "with teacher mode='true'" do
      before(:each) do
        controller.stub!(:render)
        get :show, :id => @investigation.id, :teacher_mode => "true"
      end
      it "should assign true to teacher_mode instance var" do
        assert (assigns(:teacher_mode) == true)
      end
    end
    describe "with teacher mode='false'" do
      before(:each) do
        controller.stub!(:render)
        get :show, :id => @investigation.id, :teacher_mode => "false"
      end
      it "should assign true to teacher_mode instance var" do
        assert (assigns(:teacher_mode) == false)
      end
    end
  end
end
