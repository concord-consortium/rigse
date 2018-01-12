require File.expand_path('../../spec_helper', __FILE__)
describe HomeController do
  render_views

  let(:activity) { Factory.create(      :external_activity,
                                        :name => "test activity",
                                        :publication_status => "published") }

  let(:sequence) { Factory.create(      :external_activity,
                                        :name => "test sequence",
                                        :publication_status => "published") }

  let(:interactive) { Factory.create(   :interactive,
                                        :name => "test interactive",
                                        :publication_status => "published",
                                        :external_activity_id => activity.id ) }

  before(:each) do

    #
    # Warning:
    # When the specs are run different ways sometimes the @test_settings
    # mock is used and sometimes it is not.
    # see this PT story for more details: https://www.pivotaltracker.com/story/show/145134539
    #
    @test_settings = mock("settings")
    Admin::Settings.stub(:default_settings).and_return(@test_settings)
    @test_settings.stub!(:use_student_security_questions).and_return(false)
    @test_settings.stub!(:require_user_consent?).and_return(false)
    @test_settings.stub!(:help_type).and_return('no help')
    @test_settings.stub!(:anonymous_can_browse_materials).and_return(true)
    @test_settings.stub!(:allow_default_class).and_return(false)
    @test_settings.stub!(:allow_adhoc_schools).and_return(false)
    @test_settings.stub!(:show_collections_menu).and_return(false)
    @test_settings.stub!(:auto_set_teachers_as_authors).and_return(false)
    @test_settings.stub!(:wrap_home_page_content?).and_return(true)
    @test_settings.stub!(:teacher_home_path).and_return(nil)
    controller.stub(:before_render) {
      response.template.stub(:current_settings).and_return(@test_settings)
    }
    # it appears that some previous tests leave a user logged in somehow
    # so we explicitly log in anonymous here
    login_anonymous
  end

  it "should display home page content from the current admin settings" do

    content = "Test home page content"

    @test_settings.should_receive(:home_page_content).at_least(:once).and_return(content)
    @test_settings.stub(:name).and_return("Test Settings")
    @test_settings.stub(:custom_search_path)

    get :index
    response.body.should include(content)
  end

  describe "GET /stylesheets/settings.css" do
    describe "when settings are configured to use custom styles" do
      it "should return the custom css" do
        css_text = ".some_class { font-height: 10px; }"
        @test_settings.stub(:custom_css).and_return(css_text)
        @test_settings.stub(:using_custom_css?).and_return(true)
        get :settings_css
        response.body.should include(css_text)
      end
    end
    describe "when settings are not configured to use custom styles" do
      it "should return 404" do
        @test_settings.stub(:using_custom_css?).and_return(false)
        get :settings_css
        response.should_not be_success
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
      response.body.should include(@post_params[:home_page_preview_content])
    end
  end

  describe "STEM resources" do
    before(:each) do
      @test_settings.stub!(:home_page_content).and_return("stubbed homepage content")
      @test_settings.stub(:custom_search_path)
    end

    # note: in the tests below the "slug" param is always optional
    it "should return 200 when a valid activity is used" do
      get :stem_resources, :id => activity.id
      response.should be_success
      get :stem_resources, :id => activity.id, :slug => "test"
      response.should be_success
    end

    it "should return 404 when an unknown activity is used" do
      get :stem_resources, :id => 999999999999999
      response.should_not be_success
      get :stem_resources, :id => 999999999999999, :slug => "test"
      response.should_not be_success
    end

    it "should return 200 when a valid sequence is used" do
      get :stem_resources, :id => sequence.id
      response.should be_success
      get :stem_resources, :id => sequence.id, :slug => "test"
      response.should be_success
    end

    it "should return 404 when an unknown sequence is used" do
      get :stem_resources, :id => 999999999999999
      response.should_not be_success
      get :stem_resources, :id => 999999999999999, :slug => "test"
      response.should_not be_success
    end

    it "should return 200 when a valid interactive is used" do
      get :stem_resources, :type => "interactive", :id_or_filter_value => interactive.id
      response.should redirect_to stem_resources_url(interactive.external_activity_id, activity.name.parameterize)
      get :stem_resources, :type => "interactive", :id_or_filter_value => interactive.id, :slug => "test"
      response.should redirect_to stem_resources_url(interactive.external_activity_id, activity.name.parameterize)
    end

    it "should return 404 when an unknown interactive is used" do
      get :stem_resources, :type => "interactive", :id_or_filter_value => 999999999999999
      response.should_not be_success
      get :stem_resources, :type => "interactive", :id_or_filter_value => 999999999999999, :slug => "test"
      response.should_not be_success
    end

    #
    # This should fall through to the home page as a search filter.
    #
    it "should return 200 when an unknown type is used" do
      get :stem_resources, :type => "unknown-type", :id_or_filter_value => 1
      response.should be_success
      get :stem_resources, :type => "unknown-type", :id_or_filter_value => 1, :slug => "test"
      response.should be_success
    end

    it "should include the required Javascript when a valid activity is used" do
      get :stem_resources, :id => activity.id
      response.body.should include("auto_show_lightbox_resource")
      response.body.should include("PortalPages.settings.autoShowingLightboxResource = {\"id\":#{activity.id},")
      response.body.should include("PortalPages.renderResourceLightbox(")
    end

    it "should include the required Javascript when an unknown activity is used" do
      get :stem_resources, :type => "activity", :id => 999999999999999
      response.body.should include("auto_show_lightbox_resource")
      response.body.should include("PortalPages.settings.autoShowingLightboxResource = null")
      response.body.should include("PortalPages.renderResourceLightbox(")
    end

    it "should set the start of the page title to the resource name" do
      get :stem_resources, :id => activity.id
      response.body.should include("<title>#{activity.name}")
    end
  end
end
