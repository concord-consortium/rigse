require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../spec_controller_helper')

describe Dataservice::BundleLoggersController do

  def mock_bundle_logger(stubs={})
    @mock_bundle_logger ||= mock_model(Dataservice::BundleLogger, stubs)
  end

  describe "GET index" do
    it "assigns all dataservice_bundle_loggers as @dataservice_bundle_loggers" do
      pending "Broken example"
      Dataservice::BundleLogger.stub!(:find).with(:all).and_return([mock_bundle_logger])
      get :index
      assigns[:dataservice_bundle_loggers].should == [mock_bundle_logger]
    end
  end

  describe "GET show" do
    it "assigns the requested bundle_logger as @bundle_logger" do
      pending "Broken example"
      Dataservice::BundleLogger.stub!(:find).with("37").and_return(mock_bundle_logger)
      get :show, :id => "37"
      assigns[:bundle_logger].should equal(mock_bundle_logger)
    end
  end

  describe "GET new" do
    it "assigns a new bundle_logger as @bundle_logger" do
      pending "Broken example"
      Dataservice::BundleLogger.stub!(:new).and_return(mock_bundle_logger)
      get :new
      assigns[:bundle_logger].should equal(mock_bundle_logger)
    end
  end

  describe "GET edit" do
    it "assigns the requested bundle_logger as @bundle_logger" do
      pending "Broken example"
      Dataservice::BundleLogger.stub!(:find).with("37").and_return(mock_bundle_logger)
      get :edit, :id => "37"
      assigns[:bundle_logger].should equal(mock_bundle_logger)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created bundle_logger as @bundle_logger" do
        pending "Broken example"
        Dataservice::BundleLogger.stub!(:new).with({'these' => 'params'}).and_return(mock_bundle_logger(:save => true))
        post :create, :bundle_logger => {:these => 'params'}
        assigns[:bundle_logger].should equal(mock_bundle_logger)
      end

      it "redirects to the created bundle_logger" do
        pending "Broken example"
        Dataservice::BundleLogger.stub!(:new).and_return(mock_bundle_logger(:save => true))
        post :create, :bundle_logger => {}
        response.should redirect_to(dataservice_bundle_logger_url(mock_bundle_logger))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved bundle_logger as @bundle_logger" do
        pending "Broken example"
        Dataservice::BundleLogger.stub!(:new).with({'these' => 'params'}).and_return(mock_bundle_logger(:save => false))
        post :create, :bundle_logger => {:these => 'params'}
        assigns[:bundle_logger].should equal(mock_bundle_logger)
      end

      it "re-renders the 'new' template" do
        pending "Broken example"
        Dataservice::BundleLogger.stub!(:new).and_return(mock_bundle_logger(:save => false))
        post :create, :bundle_logger => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested bundle_logger" do
        pending "Broken example"
        Dataservice::BundleLogger.should_receive(:find).with("37").and_return(mock_bundle_logger)
        mock_bundle_logger.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :bundle_logger => {:these => 'params'}
      end

      it "assigns the requested bundle_logger as @bundle_logger" do
        pending "Broken example"
        Dataservice::BundleLogger.stub!(:find).and_return(mock_bundle_logger(:update_attributes => true))
        put :update, :id => "1"
        assigns[:bundle_logger].should equal(mock_bundle_logger)
      end

      it "redirects to the bundle_logger" do
        pending "Broken example"
        Dataservice::BundleLogger.stub!(:find).and_return(mock_bundle_logger(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(dataservice_bundle_logger_url(mock_bundle_logger))
      end
    end

    describe "with invalid params" do
      it "updates the requested bundle_logger" do
        pending "Broken example"
        Dataservice::BundleLogger.should_receive(:find).with("37").and_return(mock_bundle_logger)
        mock_bundle_logger.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :bundle_logger => {:these => 'params'}
      end

      it "assigns the bundle_logger as @bundle_logger" do
        pending "Broken example"
        Dataservice::BundleLogger.stub!(:find).and_return(mock_bundle_logger(:update_attributes => false))
        put :update, :id => "1"
        assigns[:bundle_logger].should equal(mock_bundle_logger)
      end

      it "re-renders the 'edit' template" do
        pending "Broken example"
        Dataservice::BundleLogger.stub!(:find).and_return(mock_bundle_logger(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested bundle_logger" do
      pending "Broken example"
      Dataservice::BundleLogger.should_receive(:find).with("37").and_return(mock_bundle_logger)
      mock_bundle_logger.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the dataservice_bundle_loggers list" do
      pending "Broken example"
      Dataservice::BundleLogger.stub!(:find).and_return(mock_bundle_logger(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(dataservice_bundle_loggers_url)
    end
  end

end
