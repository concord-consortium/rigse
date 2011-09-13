require File.expand_path('../../spec_helper', __FILE__)#include ApplicationHelper

describe InvestigationsController do
  render_views

  before(:each) do
    @current_project = mock(
      :name => "test project",
      :using_custom_css? => false,
      :use_bitmap_snapshots? => false,
      :maven_jnlp_family => nil,
      :snapshot_enabled => false)
    Admin::Project.stub!(:default_project).and_return(@current_project)
    
    # this part is broken when the monkey patched application controller was removed
    # spec/support/controller_helper.rb
    controller.stub(:before_render) {
      response.template.stub(:net_logo_package_name).and_return("blah")
      response.template.stub_chain(:current_project).and_return(@current_project);
    }

    @admin_user = Factory.create(:user, { :email => "test@test.com", :password => "password", :password_confirmation => "password" })
    @admin_user.add_role("admin")

    stub_current_user :admin_user

    @investigation = Factory.create(:investigation, {
      :name => "test investigation",
      :description => "new decription"
    })

    Investigation.stub!(:find).and_return(@investigation)
    Investigation.stub!(:published).and_return([@investigation])
  end

  it "should display a 'duplicate' link for authorized users" do
    @investigation.should_receive(:duplicateable?).with(@logged_in_user).and_return(true)

    get :show, :id => @investigation.id

    #@response.body.should include(duplicate_link_for(@investigation))
    assert_select("a[href=?]", duplicate_investigation_url(@investigation), { :text => "duplicate", :count => 1 })
  end

  it "should not display a 'duplicate' link for unauthorized users" do
    @investigation.should_receive(:duplicateable?).with(@logged_in_user).and_return(false)

    get :show, :id => @investigation.id

    #@response.body.should_not include(duplicate_link_for(@investigation))
    assert_select("a[href=?]", duplicate_investigation_url(@investigation), { :text => "duplicate", :count => 0 })
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
end
