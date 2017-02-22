require File.expand_path('../../spec_helper', __FILE__)#include ApplicationHelper

describe InvestigationsController do
  render_views

  before(:each) do
    @current_settings = double(
      :name => "test settings",
      :using_custom_css? => false,
      :use_bitmap_snapshots? => false,
      :snapshot_enabled => false,
      :use_student_security_questions => false,
      :require_user_consent? => false)
    allow(Admin::Settings).to receive(:default_settings).and_return(@current_settings)
    
    # this part is broken when the monkey patched application controller was removed
    # spec/support/controller_helper.rb
    allow(controller).to receive(:before_render) {
      allow(response.template).to receive(:net_logo_package_name).and_return("blah")
      allow(response.template).to receive_message_chain(:current_settings).and_return(@current_settings);
    }

    @admin_user = Factory.create(:user, { :email => "test@test.com", :password => "password", :password_confirmation => "password" })
    @admin_user.add_role("admin")

    login_admin

    @investigation = Factory.create(:investigation, {
      :name => "test investigation",
      :description => "new decription"
    })

    allow(Investigation).to receive(:find).and_return(@investigation)
    allow(Investigation).to receive(:published).and_return([@investigation])
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
    expect(headers).to have_key 'Pragma'
    # note: there could be multiple pragmas, I'm not sure how that will be returned and wether this will correclty match it
    expect(headers['Pragma']).to match "no-cache"
    expect(headers).to have_key 'Cache-Control'
    expect(headers['Cache-Control']).to match "max-age=0"
    expect(headers['Cache-Control']).to match "no-cache"
    expect(headers['Cache-Control']).to match "no-store"
  end
end
