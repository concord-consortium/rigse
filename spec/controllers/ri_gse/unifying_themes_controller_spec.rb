require File.expand_path('../../../spec_helper', __FILE__)

describe RiGse::UnifyingThemesController do

  def mock_unifying_theme(stubs={})
    @mock_unifying_theme ||= mock_model(RiGse::UnifyingTheme, stubs)
  end
  
  before(:each) do
    generate_default_settings_and_jnlps_with_mocks
    # generate_portal_resources_with_mocks
    login_admin
  end
  
  describe "responding to GET index" do

    it "should expose an array of all the @unifying_themes" do
      expect(RiGse::UnifyingTheme).to receive(:all).and_return([mock_unifying_theme])
      get :index
      expect(assigns[:unifying_themes]).to eq([mock_unifying_theme])
    end

    describe "with mime type of xml" do
  
      it "should render all unifying_themes as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        expect(RiGse::UnifyingTheme).to receive(:all).and_return(unifying_themes = double("Array of UnifyingThemes"))
        expect(unifying_themes).to receive(:to_xml).and_return("generated XML")
        get :index
        expect(response.body).to eq("generated XML")
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested unifying_theme as @unifying_theme" do
      expect(RiGse::UnifyingTheme).to receive(:find).with("37").and_return(mock_unifying_theme)
      get :show, :id => "37"
      expect(assigns[:unifying_theme]).to equal(mock_unifying_theme)
    end
    
    describe "with mime type of xml" do

      it "should render the requested unifying_theme as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        expect(RiGse::UnifyingTheme).to receive(:find).with("37").and_return(mock_unifying_theme)
        expect(mock_unifying_theme).to receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        expect(response.body).to eq("generated XML")
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new unifying_theme as @unifying_theme" do
      expect(RiGse::UnifyingTheme).to receive(:new).and_return(mock_unifying_theme)
      get :new
      expect(assigns[:unifying_theme]).to equal(mock_unifying_theme)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested unifying_theme as @unifying_theme" do
      expect(RiGse::UnifyingTheme).to receive(:find).with("37").and_return(mock_unifying_theme)
      get :edit, :id => "37"
      expect(assigns[:unifying_theme]).to equal(mock_unifying_theme)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created unifying_theme as @unifying_theme" do
        expect(RiGse::UnifyingTheme).to receive(:new).with({'these' => 'params'}).and_return(mock_unifying_theme(:save => true))
        post :create, :unifying_theme => {:these => 'params'}
        expect(assigns(:unifying_theme)).to equal(mock_unifying_theme)
      end

      it "should redirect to the created unifying_theme" do
        allow(RiGse::UnifyingTheme).to receive(:new).and_return(mock_unifying_theme(:save => true))
        post :create, :unifying_theme => {}
        expect(response).to redirect_to(ri_gse_unifying_theme_url(mock_unifying_theme))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved unifying_theme as @unifying_theme" do
        allow(RiGse::UnifyingTheme).to receive(:new).with({'these' => 'params'}).and_return(mock_unifying_theme(:save => false))
        post :create, :unifying_theme => {:these => 'params'}
        expect(assigns(:unifying_theme)).to equal(mock_unifying_theme)
      end

      it "should re-render the 'new' template" do
        allow(RiGse::UnifyingTheme).to receive(:new).and_return(mock_unifying_theme(:save => false))
        post :create, :unifying_theme => {}
        expect(response).to render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested unifying_theme" do
        expect(RiGse::UnifyingTheme).to receive(:find).with("37").and_return(mock_unifying_theme)
        expect(mock_unifying_theme).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :unifying_theme => {:these => 'params'}
      end

      it "should expose the requested unifying_theme as @unifying_theme" do
        allow(RiGse::UnifyingTheme).to receive(:find).and_return(mock_unifying_theme(:update_attributes => true))
        put :update, :id => "1"
        expect(assigns(:unifying_theme)).to equal(mock_unifying_theme)
      end

      it "should redirect to the unifying_theme" do
        allow(RiGse::UnifyingTheme).to receive(:find).and_return(mock_unifying_theme(:update_attributes => true))
        put :update, :id => "1"
        expect(response).to redirect_to(ri_gse_unifying_theme_url(mock_unifying_theme))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested unifying_theme" do
        expect(RiGse::UnifyingTheme).to receive(:find).with("37").and_return(mock_unifying_theme)
        expect(mock_unifying_theme).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :unifying_theme => {:these => 'params'}
      end

      it "should expose the unifying_theme as @unifying_theme" do
        allow(RiGse::UnifyingTheme).to receive(:find).and_return(mock_unifying_theme(:update_attributes => false))
        put :update, :id => "1"
        expect(assigns(:unifying_theme)).to equal(mock_unifying_theme)
      end

      it "should re-render the 'edit' template" do
        allow(RiGse::UnifyingTheme).to receive(:find).and_return(mock_unifying_theme(:update_attributes => false))
        put :update, :id => "1"
        expect(response).to render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested unifying_theme" do
      expect(RiGse::UnifyingTheme).to receive(:find).with("37").and_return(mock_unifying_theme)
      expect(mock_unifying_theme).to receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the unifying_themes list" do
      allow(RiGse::UnifyingTheme).to receive(:find).and_return(mock_unifying_theme(:destroy => true))
      delete :destroy, :id => "1"
      expect(response).to redirect_to(unifying_themes_url)
    end

  end

end
