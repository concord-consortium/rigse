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
end
