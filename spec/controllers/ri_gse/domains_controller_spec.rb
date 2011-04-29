require 'spec_helper'

describe RiGse::DomainsController do

  def mock_domain(stubs={})
    @mock_domain ||= mock_model(RiGse::Domain, stubs)
  end
  
  before(:each) do
    generate_default_project_and_jnlps_with_mocks
    # generate_portal_resources_with_mocks
    login_admin
  end
  
  describe "responding to GET index" do

    it "should expose an array of all the @domains" do
      RiGse::Domain.should_receive(:find).with(:all).and_return([mock_domain])
      get :index
      assigns[:domains].should == [mock_domain]
    end

    describe "with mime type of xml" do
  
      it "should render all domains as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        RiGse::Domain.should_receive(:find).with(:all).and_return(domains = mock("Array of Domains"))
        domains.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested domain as @domain" do
      RiGse::Domain.should_receive(:find).with("37").and_return(mock_domain)
      get :show, :id => "37"
      assigns[:domain].should equal(mock_domain)
    end
    
    describe "with mime type of xml" do

      it "should render the requested domain as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        RiGse::Domain.should_receive(:find).with("37").and_return(mock_domain)
        mock_domain.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new domain as @domain" do
      RiGse::Domain.should_receive(:new).and_return(mock_domain)
      get :new
      assigns[:domain].should equal(mock_domain)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested domain as @domain" do
      RiGse::Domain.should_receive(:find).with("37").and_return(mock_domain)
      get :edit, :id => "37"
      assigns[:domain].should equal(mock_domain)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created domain as @domain" do
        RiGse::Domain.should_receive(:new).with({'these' => 'params'}).and_return(mock_domain(:save => true))
        post :create, :domain => {:these => 'params'}
        assigns(:domain).should equal(mock_domain)
      end

      it "should redirect to the created domain" do
        RiGse::Domain.stub!(:new).and_return(mock_domain(:save => true))
        post :create, :domain => {}
        response.should redirect_to(ri_gse_domain_url(mock_domain))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved domain as @domain" do
        RiGse::Domain.stub!(:new).with({'these' => 'params'}).and_return(mock_domain(:save => false))
        post :create, :domain => {:these => 'params'}
        assigns(:domain).should equal(mock_domain)
      end

      it "should re-render the 'new' template" do
        RiGse::Domain.stub!(:new).and_return(mock_domain(:save => false))
        post :create, :domain => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested domain" do
        RiGse::Domain.should_receive(:find).with("37").and_return(mock_domain)
        mock_domain.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :domain => {:these => 'params'}
      end

      it "should expose the requested domain as @domain" do
        RiGse::Domain.stub!(:find).and_return(mock_domain(:update_attributes => true))
        put :update, :id => "1"
        assigns(:domain).should equal(mock_domain)
      end

      it "should redirect to the domain" do
        RiGse::Domain.stub!(:find).and_return(mock_domain(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(ri_gse_domain_url(mock_domain))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested domain" do
        RiGse::Domain.should_receive(:find).with("37").and_return(mock_domain)
        mock_domain.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :domain => {:these => 'params'}
      end

      it "should expose the domain as @domain" do
        RiGse::Domain.stub!(:find).and_return(mock_domain(:update_attributes => false))
        put :update, :id => "1"
        assigns(:domain).should equal(mock_domain)
      end

      it "should re-render the 'edit' template" do
        RiGse::Domain.stub!(:find).and_return(mock_domain(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested domain" do
      RiGse::Domain.should_receive(:find).with("37").and_return(mock_domain)
      mock_domain.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the domains list" do
      RiGse::Domain.stub!(:find).and_return(mock_domain(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(domains_url)
    end

  end

end
