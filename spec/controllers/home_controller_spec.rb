require File.expand_path('../../spec_helper', __FILE__)
describe HomeController do
  render_views

  before(:each) do
    @test_settings = double("settings")
    allow(Admin::Settings).to receive(:default_settings).and_return(@test_settings)
    allow(@test_settings).to receive(:use_student_security_questions).and_return(false)
    allow(@test_settings).to receive(:require_user_consent?).and_return(false)
    allow(@test_settings).to receive(:help_type).and_return('no help')
    allow(@test_settings).to receive(:anonymous_can_browse_materials).and_return(true)
    allow(@test_settings).to receive(:allow_default_class).and_return(false)
    allow(@test_settings).to receive(:allow_adhoc_schools).and_return(false)
    allow(@test_settings).to receive(:show_collections_menu).and_return(false)
    allow(@test_settings).to receive(:auto_set_teachers_as_authors).and_return(false)
    allow(@test_settings).to receive(:wrap_home_page_content?).and_return(true)
    allow(@test_settings).to receive(:teacher_home_path).and_return(nil)
    allow(controller).to receive(:before_render) {
      allow(response.template).to receive(:current_settings).and_return(@test_settings)
    }
    # it appears that some previous tests leave a user logged in somehow
    # so we explicitly log in anonymous here
    login_anonymous
  end

  it "should display home page content from the current admin settings" do

    content = "Test home page content"

    expect(@test_settings).to receive(:home_page_content).at_least(:once).and_return(content)
    allow(@test_settings).to receive(:name).and_return("Test Settings")

    get :index
    expect(response.body).to include(content)
  end

  describe "GET /stylesheets/settings.css" do
    describe "when settings are configured to use custom styles" do
      it "should return the custom css" do
        css_text = ".some_class { font-height: 10px; }"
        allow(@test_settings).to receive(:custom_css).and_return(css_text)
        allow(@test_settings).to receive(:using_custom_css?).and_return(true)
        get :settings_css
        expect(response.body).to include(css_text)
      end
    end
    describe "when settings are not configured to use custom styles" do
      it "should return 404" do
        allow(@test_settings).to receive(:using_custom_css?).and_return(false)
        get :settings_css
        expect(response).not_to be_success
      end
    end
  end
  describe "Post preview_home_page" do
    it "should set variables to preview home page" do
      anonymous_user = Factory.next(:anonymous_user)
      @post_params = {
        :home_page_preview_content =>"<b>Home page content.</b>",
      }
      post :preview_home_page, @post_params
      assert_response :success
      expect(response.body).to include(@post_params[:home_page_preview_content])
    end
  end
end
