require File.expand_path('../../spec_helper', __FILE__)#include ApplicationHelper

describe InvestigationsController do
  render_views

  before(:each) do
    @current_settings = mock(
      :name => "test settings",
      :using_custom_css? => false,
      :use_bitmap_snapshots? => false,
      :snapshot_enabled => false,
      :use_student_security_questions => false,
      :require_user_consent? => false)
    Admin::Settings.stub!(:default_settings).and_return(@current_settings)
    
    # this part is broken when the monkey patched application controller was removed
    # spec/support/controller_helper.rb
    controller.stub(:before_render) {
      response.template.stub(:net_logo_package_name).and_return("blah")
      response.template.stub_chain(:current_settings).and_return(@current_settings);
    }

    @admin_user = Factory.create(:user, { :email => "test@test.com", :password => "password", :password_confirmation => "password" })
    @admin_user.add_role("admin")

    login_admin

    @investigation = Factory.create(:investigation, {
      :name => "test investigation",
      :description => "new decription"
    })

    Investigation.stub!(:find).and_return(@investigation)
    Investigation.stub!(:published).and_return([@investigation])
  end

  it "should render preview warning in OTML" do
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

  it "should not be cached" do
    visit investigation_path(:id => @investigation.id, :format => :dynamic_otml)
    headers = page.driver.response.headers
    headers.should have_key 'Pragma'
    # note: there could be multiple pragmas, I'm not sure how that will be returned and wether this will correclty match it
    headers['Pragma'].should match "no-cache"
    headers.should have_key 'Cache-Control'
    headers['Cache-Control'].should match "max-age=0"
    headers['Cache-Control'].should match "no-cache"
    headers['Cache-Control'].should match "no-store"
  end
end
