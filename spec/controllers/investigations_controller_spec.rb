require File.expand_path('../../spec_helper', __FILE__)#include ApplicationHelper

describe InvestigationsController do
  integrate_views

  before(:each) do
    @current_project = mock(
      :name => "test project",
      :using_custom_css? => false,
      :use_bitmap_snapshots? => false)
    Admin::Project.stub!(:default_project).and_return(@current_project)
    controller.stub(:before_render) {
      response.template.stub(:net_logo_package_name).and_return("blah")
      response.template.stub_chain(:current_project).and_return(@current_project);
    }

    @admin_user = Factory.create(:user, { :email => "test@test.com", :password => "password", :password_confirmation => "password" })
    @admin_user.add_role("admin")

    stub_current_user :admin_user

    @investigation = Factory.create(:investigation, {
      :name => "test investigation",
      :description => "new description"
    })

    Investigation.stub!(:find).and_return(@investigation)
    Investigation.stub!(:published).and_return([@investigation])
  end

  it "should display a 'duplicate' link for authorized users" do
    fails_in_themes({"assessment" => :expected}) do
    @investigation.should_receive(:duplicateable?).with(@logged_in_user).and_return(true)

    get :show, :id => @investigation.id

    #@response.body.should include(duplicate_link_for(@investigation))
    assert_select("a[href=?]", duplicate_investigation_url(@investigation), { :text => "duplicate", :count => 1 })
    end
  end

  it "should not display a 'duplicate' link for unauthorized users" do
    fails_in_themes({"assessment" => :expected}) do
    @investigation.should_receive(:duplicateable?).with(@logged_in_user).and_return(false)

    get :show, :id => @investigation.id

    #@response.body.should_not include(duplicate_link_for(@investigation))
    assert_select("a[href=?]", duplicate_investigation_url(@investigation), { :text => "duplicate", :count => 0 })
    end
  end

  it "should render prievew warning in OTML" do
    get :show, :id => @investigation.id, :format => 'otml'
    assert_select "*.warning"
  end

  it "should render overlay removing warning in dynamic_otml" do
    get :show, :id => @investigation.id, :format => 'dynamic_otml'
    assert_select "overlays" do
      assert_select "OTOverlay" do
        assert_select "deltaObjectMap" do
          assert_select "entry[key=?]", "#{@investigation.uuid}!/preview_warning"
        end
      end
    end
  end

  describe "Researcher Reports" do
    it 'should return an XLS file for the global Usage Report' do
      get :usage_report
      response.sending_file?.should be_true
      response.content_type.should eql "application/vnd.ms.excel"
    end

    it 'should return an XLS file for the global Details Report' do
      get :details_report
      response.sending_file?.should be_true
      response.content_type.should eql "application/vnd.ms.excel"
    end

    it 'should return an XLS file for the specific Usage Report' do
      get :usage_report, :id => @investigation.id
      response.sending_file?.should be_true
      response.content_type.should eql "application/vnd.ms.excel"
    end

    it 'should return an XLS file for the specific Details Report' do
      get :details_report, :id => @investigation.id
      response.sending_file?.should be_true
      response.content_type.should eql "application/vnd.ms.excel"
    end
  end

  describe "Assessments investigations" do
    # include ApplicationHelper
    before(:each) do
      @inv_params = {:investigation => {:name => "New Investigation #{UUIDTools::UUID.timestamp_create.to_s}", :description => "Desc", :publication_status => "draft", :user_id => @admin_user.id } }
      Investigation.unstub!(:find)
      Investigation.unstub!(:published)

      # we should be able to do this as a normal user
      @user = Factory.create(:user)
      stub_current_user :user
    end

    it "should create a single Page nested in a section and activity" do
      post :extended_create, @inv_params
      response.status.should eql("302 Found")
      @new_investigation = Investigation.find_by_name(@inv_params[:investigation][:name])
      @new_investigation.activities.size.should eql(1)
      @new_investigation.activities.first.sections.size.should eql(1)
      @new_investigation.activities.first.sections.first.pages.size.should eql(1)
    end

    it "should forward the user to the page show page" do
      post :extended_create, @inv_params
      @new_investigation = Investigation.find_by_name(@inv_params[:investigation][:name])
      response.should redirect_to(page_path(@new_investigation.activities.first.sections.first.pages.first))
    end

    it "should create an ExternalActivity corresponding to this investigation" do
      post :extended_create, @inv_params
      @new_investigation = Investigation.find_by_name(@inv_params[:investigation][:name])
      ea = ExternalActivity.find_by_name_and_url(@new_investigation.name, "/sc-runtime/##{@new_investigation.activities.first.id}")
      ea.should_not be_nil
      ea.append_learner_id_to_url.should be_true
    end
  end
end
