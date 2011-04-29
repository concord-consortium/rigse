require 'spec_helper'

describe Portal::ExternalUserDomainsController do

  def mock_external_user_domain(stubs={})
    @mock_external_user_domain ||= mock_model(Portal::ExternalUserDomain, stubs)
  end

  describe "GET index" do
    it "assigns all portal_external_user_domains as @portal_external_user_domains" do
      pending "Broken example"
      Portal::ExternalUserDomain.stub!(:find).with(:all).and_return([mock_external_user_domain])
      get :index
      assigns[:portal_external_user_domains].should == [mock_external_user_domain]
    end
  end

  describe "GET show" do
    it "assigns the requested external_user_domain as @external_user_domain" do
      pending "Broken example"
      Portal::ExternalUserDomain.stub!(:find).with("37").and_return(mock_external_user_domain)
      get :show, :id => "37"
      assigns[:external_user_domain].should equal(mock_external_user_domain)
    end
  end

  describe "GET new" do
    it "assigns a new external_user_domain as @external_user_domain" do
      pending "Broken example"
      Portal::ExternalUserDomain.stub!(:new).and_return(mock_external_user_domain)
      get :new
      assigns[:external_user_domain].should equal(mock_external_user_domain)
    end
  end

  describe "GET edit" do
    it "assigns the requested external_user_domain as @external_user_domain" do
      pending "Broken example"
      Portal::ExternalUserDomain.stub!(:find).with("37").and_return(mock_external_user_domain)
      get :edit, :id => "37"
      assigns[:external_user_domain].should equal(mock_external_user_domain)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created external_user_domain as @external_user_domain" do
        pending "Broken example"
        Portal::ExternalUserDomain.stub!(:new).with({'these' => 'params'}).and_return(mock_external_user_domain(:save => true))
        post :create, :external_user_domain => {:these => 'params'}
        assigns[:external_user_domain].should equal(mock_external_user_domain)
      end

      it "redirects to the created external_user_domain" do
        pending "Broken example"
        Portal::ExternalUserDomain.stub!(:new).and_return(mock_external_user_domain(:save => true))
        post :create, :external_user_domain => {}
        response.should redirect_to(portal_external_user_domain_url(mock_external_user_domain))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved external_user_domain as @external_user_domain" do
        pending "Broken example"
        Portal::ExternalUserDomain.stub!(:new).with({'these' => 'params'}).and_return(mock_external_user_domain(:save => false))
        post :create, :external_user_domain => {:these => 'params'}
        assigns[:external_user_domain].should equal(mock_external_user_domain)
      end

      it "re-renders the 'new' template" do
        pending "Broken example"
        Portal::ExternalUserDomain.stub!(:new).and_return(mock_external_user_domain(:save => false))
        post :create, :external_user_domain => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested external_user_domain" do
        pending "Broken example"
        Portal::ExternalUserDomain.should_receive(:find).with("37").and_return(mock_external_user_domain)
        mock_external_user_domain.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :external_user_domain => {:these => 'params'}
      end

      it "assigns the requested external_user_domain as @external_user_domain" do
        pending "Broken example"
        Portal::ExternalUserDomain.stub!(:find).and_return(mock_external_user_domain(:update_attributes => true))
        put :update, :id => "1"
        assigns[:external_user_domain].should equal(mock_external_user_domain)
      end

      it "redirects to the external_user_domain" do
        pending "Broken example"
        Portal::ExternalUserDomain.stub!(:find).and_return(mock_external_user_domain(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(portal_external_user_domain_url(mock_external_user_domain))
      end
    end

    describe "with invalid params" do
      it "updates the requested external_user_domain" do
        pending "Broken example"
        Portal::ExternalUserDomain.should_receive(:find).with("37").and_return(mock_external_user_domain)
        mock_external_user_domain.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :external_user_domain => {:these => 'params'}
      end

      it "assigns the external_user_domain as @external_user_domain" do
        pending "Broken example"
        Portal::ExternalUserDomain.stub!(:find).and_return(mock_external_user_domain(:update_attributes => false))
        put :update, :id => "1"
        assigns[:external_user_domain].should equal(mock_external_user_domain)
      end

      it "re-renders the 'edit' template" do
        pending "Broken example"
        Portal::ExternalUserDomain.stub!(:find).and_return(mock_external_user_domain(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested external_user_domain" do
      pending "Broken example"
      Portal::ExternalUserDomain.should_receive(:find).with("37").and_return(mock_external_user_domain)
      mock_external_user_domain.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the portal_external_user_domains list" do
      pending "Broken example"
      Portal::ExternalUserDomain.stub!(:find).and_return(mock_external_user_domain(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(portal_external_user_domains_url)
    end
  end

end
