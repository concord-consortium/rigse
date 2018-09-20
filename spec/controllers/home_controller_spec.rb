require File.expand_path('../../spec_helper', __FILE__)
describe HomeController do
  render_views

  let(:activity) { FactoryBot.create(      :external_activity,
                                        :name => "test activity",
                                        :publication_status => "published") }

  let(:sequence) { FactoryBot.create(      :external_activity,
                                        :name => "test sequence",
                                        :publication_status => "published") }

  let(:interactive) { FactoryBot.create(   :interactive,
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
    allow(@test_settings).to receive(:home_page_content).and_return('home page')
    allow(@test_settings).to receive(:about_page_content).and_return('home page')
    allow(@test_settings).to receive(:enable_member_registration?).and_return(false)
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
      anonymous_user = FactoryBot.generate(:anonymous_user)
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

  # TODO: auto-generated
  describe '#index' do
    it 'GET index' do
      get :index

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#getting_started' do
    it 'GET getting_started' do
      get :getting_started, {}, {}

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#my_classes' do
    it 'GET my_classes' do
      get :my_classes, {}, {}

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#preview_about_page' do
    it 'GET preview_about_page' do
      get :preview_about_page, {}, {}

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#readme' do
    it 'GET readme' do
      get :readme, {}, {}

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#doc' do
    it 'GET doc' do
      get :doc, document: 'document'

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#pick_signup' do
    it 'GET pick_signup' do
      get :pick_signup, {}, {}

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#about' do
    it 'GET about' do
      get :about, {}, {}

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#collections' do
    it 'GET collections' do
      get :collections, {}, {}

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#requirements' do
    it 'GET requirements' do
      get :requirements, {}, {}

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#admin' do
    it 'GET admin' do
      get :admin, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#authoring' do
    it 'GET authoring' do
      get :authoring, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#authoring_site_redirect' do
    it 'GET authoring_site_redirect' do
      get :authoring_site_redirect, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#name_for_clipboard_data' do
    it 'GET name_for_clipboard_data' do
      get :name_for_clipboard_data, {}, {}

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#missing_installer' do
    it 'GET missing_installer' do
      get :missing_installer, {}, {}

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#test_exception' do
    it 'GET test_exception' do
      expect { get :test_exception }.to raise_error(RuntimeError)
    end
  end

  # TODO: auto-generated
  describe '#report' do
    xit 'GET report' do
      get :report, {}, {}

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#recent_activity' do
    it 'GET recent_activity' do
      get :recent_activity, {}, {}

      expect(response).to have_http_status(:redirect)
    end
  end

end
