require File.expand_path('../../../spec_helper', __FILE__)

describe Admin::SettingsController do

  def mock_settings(stubs={})
    unless stubs.empty?
      stubs.each do |key, value|
        allow(@mock_settings).to receive(key).and_return(value)
      end
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
      assert_response :redirect
    end
  end

  describe "GET index for managers" do
    render_views

    it "only allows managers to edit the current settings and only shows them the information they can change" do
      settings = Factory.create(:admin_settings, :active => true)
      second_settings = Factory.create(:admin_settings)
      allow(Admin::Settings).to receive(:default_settings).and_return(settings)

      login_manager
      
      get :index
      
      assert_response :success
      assert_template :partial => "_show_for_managers"

      expect(assigns[:admin_settings].size).to be(1)
      expect(assigns[:admin_settings]).to include(settings)
      expect(assigns[:admin_settings]).not_to include(second_settings)
    end
  end

  describe "GET show" do
    it "assigns the requested settings as @settings" do
      expect(Admin::Settings).to receive(:find).with("37").and_return(mock_settings)
      get :show, :id => "37"
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
      get :edit, :id => "37"
      expect(assigns[:admin_settings]).to equal(mock_settings)
    end

    it "uses default content if home_page_content is empty" do
      allow(mock_settings).to receive(:home_page_content).and_return(nil)
      expect(mock_settings).to receive(:home_page_content=)
      get :edit, :id => "37"
    end

    it "uses the value of home_page_content if it is not empty" do
      allow(mock_settings).to receive(:home_page_content).and_return("test content")
      expect(mock_settings).not_to receive(:home_page_content=)
      get :edit, :id => "37"
    end
  end

  describe "GET edit for managers" do
    render_views

    it "renders the _form_for_managers partial" do
      settings = Factory.create(:admin_settings)
      expect(Admin::Settings).to receive(:find).with("37").and_return(settings)

      login_manager

      get :edit, :id => "37"

      assert_response :success
      assert_template :partial => "_form_for_managers"
      
      expect(response.body).to have_selector("*[name='admin_settings[home_page_content]']")

      (settings.attributes.keys - ["home_page_content","custom_css","wrap_home_page_content"]).each do |attribute|
        expect(response.body).not_to have_selector("*[name='admin_settings[#{attribute}]']")
      end
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created settings as @settings" do
        expect(Admin::Settings).to receive(:new).with({'these' => 'params'}).and_return(mock_settings(:save => true))
        expect(mock_settings).to receive(:save).and_return(mock_settings(:save => true))
        post :create, :admin_settings => {:these => 'params'}
        expect(assigns[:admin_settings]).to equal(mock_settings)
      end

      it "redirects to the created settings" do
        expect(Admin::Settings).to receive(:new).and_return(mock_settings(:save => true))
        expect(mock_settings).to receive(:save).and_return(mock_settings(:save => true))
        post :create, :admin_settings => {}
        expect(response).to redirect_to(admin_setting_url(mock_settings))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved settings as @settings" do
        expect(Admin::Settings).to receive(:new).with({'these' => 'params'}).and_return(mock_settings(:save => false))
        expect(mock_settings).to receive(:save).and_return(mock_settings(:save => false))
        post :create, :admin_settings => {:these => 'params'}
        expect(assigns[:admin_settings]).to equal(mock_settings)
      end

      it "re-renders the 'new' template" do
        expect(Admin::Settings).to receive(:new).and_return(mock_settings(:save => false))
        expect(mock_settings).to receive(:save).and_return(false)
        post :create, :admin_settings => {}
        expect(response).to redirect_to(new_admin_setting_url)
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested settings" do
        expect(Admin::Settings).to receive(:find).with("37").and_return(mock_settings)
        expect(mock_settings).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :admin_settings => {:these => 'params'}
      end

      it "assigns the requested settings as @settings" do
        expect(Admin::Settings).to receive(:find).and_return(mock_settings(:update_attributes => true))
        expect(mock_settings).to receive(:update_attributes).and_return(mock_settings(:save => true))
        put :update, :id => "1"
        expect(assigns[:admin_settings]).to equal(mock_settings)
      end

      it "redirects to the settings" do
        expect(Admin::Settings).to receive(:find).and_return(mock_settings(:update_attributes => true))
        expect(mock_settings).to receive(:update_attributes).and_return(mock_settings(:save => true))
        put :update, :id => "1"
        expect(response).to redirect_to(admin_setting_url(mock_settings))
      end
    end

    describe "with invalid params" do
      it "updates the requested settings" do
        expect(Admin::Settings).to receive(:find).with("37").and_return(mock_settings)
        expect(mock_settings).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :admin_settings => {:these => 'params'}
      end

      it "assigns the settings as @settings" do
        expect(Admin::Settings).to receive(:find).and_return(mock_settings(:update_attributes => false))
        expect(mock_settings).to receive(:update_attributes).and_return(mock_settings(:update_attributes => false))
        put :update, :id => "1"
        expect(assigns[:admin_settings]).to equal(mock_settings)
      end

      it "re-renders the 'edit' template" do
        expect(Admin::Settings).to receive(:find).and_return(mock_settings(:update_attributes => false))
        expect(mock_settings).to receive(:update_attributes).and_return(mock_settings(:update_attributes => false))
        put :update, :id => "1"
        expect(response).to redirect_to(admin_setting_url(mock_settings))
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested settings" do
      expect(Admin::Settings).to receive(:find).with("37").and_return(mock_settings)
      expect(mock_settings).to receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the admin_settings list" do
      expect(Admin::Settings).to receive(:find).and_return(mock_settings(:destroy => true))
      expect(mock_settings).to receive(:destroy)
      delete :destroy, :id => "1"
      expect(response).to redirect_to(admin_settings_url)
    end
  end

end
