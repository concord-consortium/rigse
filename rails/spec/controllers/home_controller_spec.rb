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
      post :preview_home_page, params: @post_params
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
      get :stem_resources, params: { :id => activity.id }
      expect(response).to be_success
      get :stem_resources, params: { :id => activity.id, :slug => "test" }
      expect(response).to be_success
    end

    it "should return 404 when an unknown activity is used" do
      get :stem_resources, params: { :id => 999999999999999 }
      expect(response).not_to be_success
      get :stem_resources, params: { :id => 999999999999999, :slug => "test" }
      expect(response).not_to be_success
    end

    it "should return 200 when a valid sequence is used" do
      get :stem_resources, params: { :id => sequence.id }
      expect(response).to be_success
      get :stem_resources, params: { :id => sequence.id, :slug => "test" }
      expect(response).to be_success
    end

    it "should return 404 when an unknown sequence is used" do
      get :stem_resources, params: { :id => 999999999999999 }
      expect(response).not_to be_success
      get :stem_resources, params: { :id => 999999999999999, :slug => "test" }
      expect(response).not_to be_success
    end

    it "should return 200 when a valid interactive is used" do
      get :stem_resources, params: { :type => "interactive", :id_or_filter_value => interactive.id }
      expect(response).to redirect_to stem_resources_url(interactive.external_activity_id, activity.name.parameterize)
      get :stem_resources, params: { :type => "interactive", :id_or_filter_value => interactive.id, :slug => "test" }
      expect(response).to redirect_to stem_resources_url(interactive.external_activity_id, activity.name.parameterize)
    end

    it "should return 404 when an unknown interactive is used" do
      get :stem_resources, params: { :type => "interactive", :id_or_filter_value => 999999999999999 }
      expect(response).not_to be_success
      get :stem_resources, params: { :type => "interactive", :id_or_filter_value => 999999999999999, :slug => "test" }
      expect(response).not_to be_success
    end

    #
    # This should fall through to the home page as a search filter.
    #
    it "should return 200 when an unknown type is used" do
      get :stem_resources, params: { :type => "unknown-type", :id_or_filter_value => 1 }
      expect(response).to be_success
      get :stem_resources, params: { :type => "unknown-type", :id_or_filter_value => 1, :slug => "test" }
      expect(response).to be_success
    end

    it "should include the required Javascript when a valid activity is used" do
      get :stem_resources, params: { :id => activity.id }
      expect(response.body).to include("auto_show_lightbox_resource")
      expect(response.body).to include("PortalComponents.settings.autoShowingLightboxResource = {\"id\":#{activity.id},")
      expect(response.body).to include("PortalComponents.renderResourceLightbox(")
    end

    it "should include the required Javascript when an unknown activity is used" do
      get :stem_resources, params: { :type => "activity", :id => 999999999999999 }
      expect(response.body).to include("auto_show_lightbox_resource")
      expect(response.body).to include("PortalComponents.settings.autoShowingLightboxResource = null")
      expect(response.body).to include("PortalComponents.renderResourceLightbox(")
    end

    it "should set the start of the page title to the resource name" do
      get :stem_resources, params: { :id => activity.id }
      expect(response.body).to include("<title>#{activity.name}")
    end
  end

  describe '#my_classes' do
    let(:school)       { FactoryBot.create(:portal_school) }
    let(:teacher_user) { FactoryBot.create(:confirmed_user, login: "teacher_user") }
    let(:teacher)      { FactoryBot.create(:portal_teacher, user: teacher_user, schools: [school]) }
    let(:course)       { FactoryBot.create(:portal_course, name: "test course", school: school) }
    let(:clazz)        { FactoryBot.create(:portal_clazz, teachers: [teacher], course: course) }
    let(:student_user) { FactoryBot.create(:confirmed_user, login: "student_user") }
    let(:student)      { FactoryBot.create(:portal_student, user: student_user) }

    before(:each) do
      allow(@test_settings).to receive(:default_cohort).and_return(nil)
      allow(@test_settings).to receive(:enabled_bookmark_types).and_return(["Portal::GenericBookmark"])
      student.add_clazz(clazz)
      sign_in student_user
    end

    describe "without bookmarks" do
      it 'GET my_classes should not include class links' do
        get :my_classes

        expect(response).to have_http_status(:ok)
        expect(response.body).to_not include("<h3>Class Links</h3>")
      end
    end

    describe "with bookmarks" do
      let(:bookmark1) { FactoryBot.create(:generic_bookmark, name: "Example Bookmark 1", url: "http://example.com/example1", user: teacher_user, clazz: clazz) }
      let(:bookmark2) { FactoryBot.create(:generic_bookmark, name: "Example Bookmark 2", url: "http://example.com/example2", user: teacher_user, clazz: clazz, is_visible: false) }
      let(:bookmark3) { FactoryBot.create(:generic_bookmark, name: "Example Bookmark 3", url: "http://example.com/example3", user: teacher_user, clazz: clazz) }

      before(:each) do
        # load bookmarks so they exists at get time
        bookmark1
        bookmark2
        bookmark3
      end

      it 'GET my_classes should include class links' do
        get :my_classes

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("<h3>Class Links</h3>")
        expect(response.body).to include("<a href='/portal/bookmark/visit/#{bookmark1.id}' target='_blank'>Example Bookmark 1</a>")
        expect(response.body).to_not include("<a href='/portal/bookmark/visit/#{bookmark2.id}' target='_blank'>Example Bookmark 2</a>")
        expect(response.body).to include("<a href='/portal/bookmark/visit/#{bookmark3.id}' target='_blank'>Example Bookmark 3</a>")
      end
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
      get :getting_started

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#preview_about_page' do
    it 'GET preview_about_page' do
      get :preview_about_page

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#readme' do
    it 'GET readme' do
      get :readme

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#doc' do
    it 'GET doc' do
      get :doc, params: { document: 'document' }

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#pick_signup' do
    it 'GET pick_signup' do
      get :pick_signup

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#about' do
    it 'GET about' do
      get :about

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#collections' do
    it 'GET collections' do
      get :collections

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#requirements' do
    it 'GET requirements' do
      get :requirements

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#admin' do
    it 'GET admin' do
      get :admin

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#authoring' do
    it 'GET authoring' do
      get :authoring

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#authoring_site_redirect' do
    it 'GET authoring_site_redirect' do
      get :authoring_site_redirect, params: {id: 1}

      expect(response).to have_http_status(:redirect)
    end
  end

  # TODO: auto-generated
  describe '#name_for_clipboard_data' do
    it 'GET name_for_clipboard_data' do
      get :name_for_clipboard_data

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#missing_installer' do
    it 'GET missing_installer' do
      get :missing_installer, params: {os: 'osx'}

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
      get :report

      expect(response).to have_http_status(:ok)
    end
  end

  # TODO: auto-generated
  describe '#recent_activity' do
    it 'GET recent_activity' do
      get :recent_activity

      expect(response).to have_http_status(:redirect)
    end
  end

end
