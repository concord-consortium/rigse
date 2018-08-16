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
    allow(@test_settings).to receive(:custom_search_path)

    get :index
    expect(response.body).to include(content)
  end

  describe "Post preview_home_page" do
    it "should set variables to preview home page" do
      anonymous_user = Factory.next(:anonymous_user)
      @post_params = {
        :home_page_preview_content =>"<b>Home page content.</b>",
      }
      post :preview_home_page, @post_params
      expect(response).to be_success
      expect(response.body).to include(@post_params[:home_page_preview_content])
    end
  end

  describe "STEM resources" do
    before(:each) do
      allow(@test_settings).to receive(:home_page_content).and_return("stubbed homepage content")
      allow(@test_settings).to receive(:custom_search_path)
    end

    # note: in the tests below the "slug" param is always optional
    it "should return 200 when a valid activity is used" do
      get :stem_resources, :id => activity.id
      expect(response).to be_success
      get :stem_resources, :id => activity.id, :slug => "test"
      expect(response).to be_success
    end

    it "should return 404 when an unknown activity is used" do
      get :stem_resources, :id => 999999999999999
      expect(response).not_to be_success
      get :stem_resources, :id => 999999999999999, :slug => "test"
      expect(response).not_to be_success
    end

    it "should return 200 when a valid sequence is used" do
      get :stem_resources, :id => sequence.id
      expect(response).to be_success
      get :stem_resources, :id => sequence.id, :slug => "test"
      expect(response).to be_success
    end

    it "should return 404 when an unknown sequence is used" do
      get :stem_resources, :id => 999999999999999
      expect(response).not_to be_success
      get :stem_resources, :id => 999999999999999, :slug => "test"
      expect(response).not_to be_success
    end

    it "should return 200 when a valid interactive is used" do
      get :stem_resources, :type => "interactive", :id_or_filter_value => interactive.id
      expect(response).to redirect_to stem_resources_url(interactive.external_activity_id, activity.name.parameterize)
      get :stem_resources, :type => "interactive", :id_or_filter_value => interactive.id, :slug => "test"
      expect(response).to redirect_to stem_resources_url(interactive.external_activity_id, activity.name.parameterize)
    end

    it "should return 404 when an unknown interactive is used" do
      get :stem_resources, :type => "interactive", :id_or_filter_value => 999999999999999
      expect(response).not_to be_success
      get :stem_resources, :type => "interactive", :id_or_filter_value => 999999999999999, :slug => "test"
      expect(response).not_to be_success
    end

    #
    # This should fall through to the home page as a search filter.
    #
    it "should return 200 when an unknown type is used" do
      get :stem_resources, :type => "unknown-type", :id_or_filter_value => 1
      expect(response).to be_success
      get :stem_resources, :type => "unknown-type", :id_or_filter_value => 1, :slug => "test"
      expect(response).to be_success
    end

    it "should include the required Javascript when a valid activity is used" do
      get :stem_resources, :id => activity.id
      expect(response.body).to include("auto_show_lightbox_resource")
      expect(response.body).to include("PortalPages.settings.autoShowingLightboxResource = {\"id\":#{activity.id},")
      expect(response.body).to include("PortalPages.renderResourceLightbox(")
    end

    it "should include the required Javascript when an unknown activity is used" do
      get :stem_resources, :type => "activity", :id => 999999999999999
      expect(response.body).to include("auto_show_lightbox_resource")
      expect(response.body).to include("PortalPages.settings.autoShowingLightboxResource = null")
      expect(response.body).to include("PortalPages.renderResourceLightbox(")
    end

    it "should set the start of the page title to the resource name" do
      get :stem_resources, :id => activity.id
      expect(response.body).to include("<title>#{activity.name}")
    end
  end
end
