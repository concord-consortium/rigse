require File.expand_path('../../../spec_helper', __FILE__)

describe Admin::SettingsController do

  def mock_settings(stubs={})
    stubs.each do |key, value|
      allow(@mock_settings).to receive(key).and_return(value)
    end
    @mock_settings
  end

  before(:each) do
    generate_default_settings_and_jnlps_with_mocks
    generate_portal_resources_with_mocks
    login_admin
  end

  describe "GET index" do
    it "assigns all admin_settings as @admin_settings" do
      expect(Admin::Settings).to receive(:search).with(nil, nil, nil).and_return([mock_settings])
      get :index
      expect(assigns[:admin_settings]).to eq([mock_settings])
    end

    it "doesn't allow anybody who isn't an admin or manager to access to index" do
      logout_user
      get :index
      expect(response.status).to eq(302)
    end
  end

  describe "GET index for managers" do
    render_views

    it "only allows managers to edit the current settings" do
      settings = FactoryBot.create(:admin_settings, :active => true)
      second_settings = FactoryBot.create(:admin_settings)
      allow(Admin::Settings).to receive(:default_settings).and_return(settings)

      login_manager

      get :index

      expect(response).to be_successful

      expect(assigns[:admin_settings].size).to be(1)
      expect(assigns[:admin_settings]).to include(settings)
      expect(assigns[:admin_settings]).not_to include(second_settings)
    end
  end

  describe "GET show" do
    it "assigns the requested settings as @settings" do
      expect(Admin::Settings).to receive(:find).with("37").and_return(mock_settings)
      get :show, params: { :id => "37" }
      expect(assigns[:admin_settings]).to equal(mock_settings)
    end
  end

  describe "GET new" do
    it "assigns a new settings as @settings" do
      expect(Admin::Settings).to receive(:new).and_return(mock_settings)
      get :new
      expect(assigns[:admin_settings]).to equal(mock_settings)
    end
  end

  describe "GET edit" do
    before(:each) do
      allow(mock_settings).to receive(:home_page_content=).and_return("") # Our controller uses this now, to set default content
      expect(Admin::Settings).to receive(:find).with("37").and_return(mock_settings)
    end

    it "assigns the requested settings as @admin_settings" do
      get :edit, params: { :id => "37" }
      expect(assigns[:admin_settings]).to equal(mock_settings)
    end

    it "no longer uses default content if home_page_content is empty" do
      allow(mock_settings).to receive(:home_page_content).and_return(nil)
      expect(mock_settings).not_to receive(:home_page_content=)
      get :edit, params: { :id => "37" }
    end

    it "uses the value of home_page_content if it is not empty" do
      allow(mock_settings).to receive(:home_page_content).and_return("test content")
      expect(mock_settings).not_to receive(:home_page_content=)
      get :edit, params: { :id => "37" }
    end
  end

  describe "GET edit for managers" do
    render_views

    it "renders the _form for managers" do
      settings = FactoryBot.create(:admin_settings)
      expect(Admin::Settings).to receive(:find).with("37").and_return(settings)

      login_manager

      get :edit, params: { :id => "37" }

      expect(response).to be_successful

      expect(response.body).to have_selector("*[name='admin_settings[home_page_content]']")

      (
        ["teachers_can_author", "use_student_security_questions",
        "allow_default_class", "require_user_consent", "show_collections_menu"]
      ).each do |attribute|
        expect(response.body).to have_selector("*[name='admin_settings[#{attribute}]']")
      end
    end
  end

  describe "POST create" do
    let(:params) { { description: 'test' } }
    describe "with valid params" do
      it "assigns a newly created settings as @settings" do
        expect(Admin::Settings).to receive(:new).with(permit_params!(params)).and_return(mock_settings(:save => true))
        expect(mock_settings).to receive(:save).and_return(mock_settings(:save => true))
        post :create, params: { admin_settings: params }
        expect(assigns[:admin_settings]).to equal(mock_settings)
      end

      it "redirects to the created settings" do
        expect(Admin::Settings).to receive(:new).and_return(mock_settings(:save => true))
        expect(mock_settings).to receive(:save).and_return(mock_settings(:save => true))
        post :create, params: { admin_settings: {} }
        expect(response).to redirect_to(admin_setting_url(mock_settings))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved settings as @settings" do
        expect(Admin::Settings).to receive(:new).with(permit_params!(params)).and_return(mock_settings(:save => false))
        expect(mock_settings).to receive(:save).and_return(mock_settings(:save => false))
        post :create, params: { admin_settings: params }
        expect(assigns[:admin_settings]).to equal(mock_settings)
      end

      it "re-renders the 'new' template" do
        expect(Admin::Settings).to receive(:new).and_return(mock_settings(:save => false))
        expect(mock_settings).to receive(:save).and_return(false)

        # it should just render the new template:
        expect(post :create, params: { admin_settings: params }).to render_template(:new)
      end
    end

  end

  describe "PUT update" do

    let(:admin_settings_params) {{
      "description" => "test settings"
    }}

    describe "with valid params" do
      it "updates the requested settings" do
        expect(Admin::Settings).to receive(:find).with("37").and_return(mock_settings)
        expect(mock_settings).to receive(:update_attributes).with(permit_params!(admin_settings_params))
        put :update, params: { :id => "37", :admin_settings => admin_settings_params }
      end

      it "assigns the requested settings as @settings" do
        expect(Admin::Settings).to receive(:find).and_return(mock_settings(:update_attributes => true))
        expect(mock_settings).to receive(:update_attributes).and_return(mock_settings(:save => true))
        put :update, params: { :id => "1" }
        expect(assigns[:admin_settings]).to equal(mock_settings)
      end

      it "redirects to the settings" do
        expect(Admin::Settings).to receive(:find).and_return(mock_settings(:update_attributes => true))
        expect(mock_settings).to receive(:update_attributes).and_return(mock_settings(:save => true))
        put :update, params: { :id => "1" }
        expect(response).to redirect_to(admin_setting_url(mock_settings))
      end
    end

    describe "with invalid params" do
      it "updates the requested settings" do
        expect(Admin::Settings).to receive(:find).with("37").and_return(mock_settings)
        expect(mock_settings).to receive(:update_attributes).with(permit_params!(admin_settings_params))
        put :update, params: { :id => "37", :admin_settings => admin_settings_params }
      end

      it "assigns the settings as @settings" do
        expect(Admin::Settings).to receive(:find).and_return(mock_settings(:update_attributes => false))
        expect(mock_settings).to receive(:update_attributes).and_return(mock_settings(:update_attributes => false))
        put :update, params: { :id => "1" }
        expect(assigns[:admin_settings]).to equal(mock_settings)
      end

      it "re-renders the 'edit' template" do
        expect(Admin::Settings).to receive(:find).and_return(mock_settings(:update_attributes => false))
        expect(mock_settings).to receive(:update_attributes).and_return(mock_settings(:update_attributes => false))
        put :update, params: { :id => "1" }
        expect(response).to redirect_to(admin_setting_url(mock_settings))
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested settings" do
      expect(Admin::Settings).to receive(:find).with("37").and_return(mock_settings)
      expect(mock_settings).to receive(:destroy)
      delete :destroy, params: { :id => "37" }
    end

    it "redirects to the admin_settings list" do
      expect(Admin::Settings).to receive(:find).and_return(mock_settings(:destroy => true))
      expect(mock_settings).to receive(:destroy)
      delete :destroy, params: { :id => "1" }
      expect(response).to redirect_to(admin_settings_url)
    end
  end
end
