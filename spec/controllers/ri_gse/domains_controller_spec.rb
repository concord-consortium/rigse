require File.expand_path('../../../spec_helper', __FILE__)

describe RiGse::DomainsController do

  def mock_domain(stubs={})
    @mock_domain ||= mock_model(RiGse::Domain, stubs)
  end
  
  before(:each) do
    generate_default_settings_and_jnlps_with_mocks
    # generate_portal_resources_with_mocks
    login_admin
  end
  
  describe "responding to GET index" do

    it "should expose an array of all the @domains" do
      expect(RiGse::Domain).to receive(:all).and_return([mock_domain])
      get :index
      expect(assigns[:domains]).to eq([mock_domain])
    end

    describe "with mime type of xml" do
  
      it "should render all domains as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        expect(RiGse::Domain).to receive(:all).and_return(domains = double("Array of Domains"))
        expect(domains).to receive(:to_xml).and_return("generated XML")
        get :index
        expect(response.body).to eq("generated XML")
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested domain as @domain" do
      expect(RiGse::Domain).to receive(:find).with("37").and_return(mock_domain)
      get :show, :id => "37"
      expect(assigns[:domain]).to equal(mock_domain)
    end
    
    describe "with mime type of xml" do

      it "should render the requested domain as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        expect(RiGse::Domain).to receive(:find).with("37").and_return(mock_domain)
        expect(mock_domain).to receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        expect(response.body).to eq("generated XML")
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new domain as @domain" do
      expect(RiGse::Domain).to receive(:new).and_return(mock_domain)
      get :new
      expect(assigns[:domain]).to equal(mock_domain)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested domain as @domain" do
      expect(RiGse::Domain).to receive(:find).with("37").and_return(mock_domain)
      get :edit, :id => "37"
      expect(assigns[:domain]).to equal(mock_domain)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created domain as @domain" do
        expect(RiGse::Domain).to receive(:new).with({'these' => 'params'}).and_return(mock_domain(:save => true))
        post :create, :domain => {:these => 'params'}
        expect(assigns(:domain)).to equal(mock_domain)
      end

      it "should redirect to the created domain" do
        allow(RiGse::Domain).to receive(:new).and_return(mock_domain(:save => true))
        post :create, :domain => {}
        expect(response).to redirect_to(ri_gse_domain_url(mock_domain))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved domain as @domain" do
        allow(RiGse::Domain).to receive(:new).with({'these' => 'params'}).and_return(mock_domain(:save => false))
        post :create, :domain => {:these => 'params'}
        expect(assigns(:domain)).to equal(mock_domain)
      end

      it "should re-render the 'new' template" do
        allow(RiGse::Domain).to receive(:new).and_return(mock_domain(:save => false))
        post :create, :domain => {}
        expect(response).to render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested domain" do
        expect(RiGse::Domain).to receive(:find).with("37").and_return(mock_domain)
        expect(mock_domain).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :domain => {:these => 'params'}
      end

      it "should expose the requested domain as @domain" do
        allow(RiGse::Domain).to receive(:find).and_return(mock_domain(:update_attributes => true))
        put :update, :id => "1"
        expect(assigns(:domain)).to equal(mock_domain)
      end

      it "should redirect to the domain" do
        allow(RiGse::Domain).to receive(:find).and_return(mock_domain(:update_attributes => true))
        put :update, :id => "1"
        expect(response).to redirect_to(ri_gse_domain_url(mock_domain))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested domain" do
        expect(RiGse::Domain).to receive(:find).with("37").and_return(mock_domain)
        expect(mock_domain).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :domain => {:these => 'params'}
      end

      it "should expose the domain as @domain" do
        allow(RiGse::Domain).to receive(:find).and_return(mock_domain(:update_attributes => false))
        put :update, :id => "1"
        expect(assigns(:domain)).to equal(mock_domain)
      end

      it "should re-render the 'edit' template" do
        allow(RiGse::Domain).to receive(:find).and_return(mock_domain(:update_attributes => false))
        put :update, :id => "1"
        expect(response).to render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested domain" do
      expect(RiGse::Domain).to receive(:find).with("37").and_return(mock_domain)
      expect(mock_domain).to receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the domains list" do
      allow(RiGse::Domain).to receive(:find).and_return(mock_domain(:destroy => true))
      delete :destroy, :id => "1"
      expect(response).to redirect_to(domains_url)
    end

  end

end
