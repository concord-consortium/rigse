require 'spec_helper'

describe HelpRequestsController do

  def mock_help_request(stubs={})
    @mock_help_request ||= mock_model(HelpRequest, stubs)
  end

  describe "GET index" do
    it "assigns all help_requests as @help_requests" do
      HelpRequest.stub(:find).with(:all).and_return([mock_help_request])
      get :index
      assigns[:help_requests].should == [mock_help_request]
    end
  end

  describe "GET show" do
    it "assigns the requested help_request as @help_request" do
      HelpRequest.stub(:find).with("37").and_return(mock_help_request)
      get :show, :id => "37"
      assigns[:help_request].should equal(mock_help_request)
    end
  end

  describe "GET new" do
    it "assigns a new help_request as @help_request" do
      HelpRequest.stub(:new).and_return(mock_help_request)
      get :new
      assigns[:help_request].should equal(mock_help_request)
    end
  end

  describe "GET edit" do
    it "assigns the requested help_request as @help_request" do
      HelpRequest.stub(:find).with("37").and_return(mock_help_request)
      get :edit, :id => "37"
      assigns[:help_request].should equal(mock_help_request)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created help_request as @help_request" do
        HelpRequest.stub(:new).with({'these' => 'params'}).and_return(mock_help_request(:save => true))
        post :create, :help_request => {:these => 'params'}
        assigns[:help_request].should equal(mock_help_request)
      end

      it "redirects to the created help_request" do
        HelpRequest.stub(:new).and_return(mock_help_request(:save => true))
        post :create, :help_request => {}
        response.should redirect_to(help_request_url(mock_help_request))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved help_request as @help_request" do
        HelpRequest.stub(:new).with({'these' => 'params'}).and_return(mock_help_request(:save => false))
        post :create, :help_request => {:these => 'params'}
        assigns[:help_request].should equal(mock_help_request)
      end

      it "re-renders the 'new' template" do
        HelpRequest.stub(:new).and_return(mock_help_request(:save => false))
        post :create, :help_request => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested help_request" do
        HelpRequest.should_receive(:find).with("37").and_return(mock_help_request)
        mock_help_request.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :help_request => {:these => 'params'}
      end

      it "assigns the requested help_request as @help_request" do
        HelpRequest.stub(:find).and_return(mock_help_request(:update_attributes => true))
        put :update, :id => "1"
        assigns[:help_request].should equal(mock_help_request)
      end

      it "redirects to the help_request" do
        HelpRequest.stub(:find).and_return(mock_help_request(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(help_request_url(mock_help_request))
      end
    end

    describe "with invalid params" do
      it "updates the requested help_request" do
        HelpRequest.should_receive(:find).with("37").and_return(mock_help_request)
        mock_help_request.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :help_request => {:these => 'params'}
      end

      it "assigns the help_request as @help_request" do
        HelpRequest.stub(:find).and_return(mock_help_request(:update_attributes => false))
        put :update, :id => "1"
        assigns[:help_request].should equal(mock_help_request)
      end

      it "re-renders the 'edit' template" do
        HelpRequest.stub(:find).and_return(mock_help_request(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested help_request" do
      HelpRequest.should_receive(:find).with("37").and_return(mock_help_request)
      mock_help_request.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the help_requests list" do
      HelpRequest.stub(:find).and_return(mock_help_request(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(help_requests_url)
    end
  end

end
