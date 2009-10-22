require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../spec_controller_helper')

describe Dataservice::ConsoleLoggersController do

  def mock_console_logger(stubs={})
    @mock_console_logger ||= mock_model(Dataservice::ConsoleLogger, stubs)
  end

  describe "GET index" do
    it "assigns all dataservice_console_loggers as @dataservice_console_loggers" do
      Dataservice::ConsoleLogger.stub!(:find).with(:all).and_return([mock_console_logger])
      get :index
      assigns[:dataservice_console_loggers].should == [mock_console_logger]
    end
  end

  describe "GET show" do
    it "assigns the requested console_logger as @console_logger" do
      Dataservice::ConsoleLogger.stub!(:find).with("37").and_return(mock_console_logger)
      get :show, :id => "37"
      assigns[:console_logger].should equal(mock_console_logger)
    end
  end

  describe "GET new" do
    it "assigns a new console_logger as @console_logger" do
      Dataservice::ConsoleLogger.stub!(:new).and_return(mock_console_logger)
      get :new
      assigns[:console_logger].should equal(mock_console_logger)
    end
  end

  describe "GET edit" do
    it "assigns the requested console_logger as @console_logger" do
      Dataservice::ConsoleLogger.stub!(:find).with("37").and_return(mock_console_logger)
      get :edit, :id => "37"
      assigns[:console_logger].should equal(mock_console_logger)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created console_logger as @console_logger" do
        Dataservice::ConsoleLogger.stub!(:new).with({'these' => 'params'}).and_return(mock_console_logger(:save => true))
        post :create, :console_logger => {:these => 'params'}
        assigns[:console_logger].should equal(mock_console_logger)
      end

      it "redirects to the created console_logger" do
        Dataservice::ConsoleLogger.stub!(:new).and_return(mock_console_logger(:save => true))
        post :create, :console_logger => {}
        response.should redirect_to(dataservice_console_logger_url(mock_console_logger))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved console_logger as @console_logger" do
        Dataservice::ConsoleLogger.stub!(:new).with({'these' => 'params'}).and_return(mock_console_logger(:save => false))
        post :create, :console_logger => {:these => 'params'}
        assigns[:console_logger].should equal(mock_console_logger)
      end

      it "re-renders the 'new' template" do
        Dataservice::ConsoleLogger.stub!(:new).and_return(mock_console_logger(:save => false))
        post :create, :console_logger => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested console_logger" do
        Dataservice::ConsoleLogger.should_receive(:find).with("37").and_return(mock_console_logger)
        mock_console_logger.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :console_logger => {:these => 'params'}
      end

      it "assigns the requested console_logger as @console_logger" do
        Dataservice::ConsoleLogger.stub!(:find).and_return(mock_console_logger(:update_attributes => true))
        put :update, :id => "1"
        assigns[:console_logger].should equal(mock_console_logger)
      end

      it "redirects to the console_logger" do
        Dataservice::ConsoleLogger.stub!(:find).and_return(mock_console_logger(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(dataservice_console_logger_url(mock_console_logger))
      end
    end

    describe "with invalid params" do
      it "updates the requested console_logger" do
        Dataservice::ConsoleLogger.should_receive(:find).with("37").and_return(mock_console_logger)
        mock_console_logger.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :console_logger => {:these => 'params'}
      end

      it "assigns the console_logger as @console_logger" do
        Dataservice::ConsoleLogger.stub!(:find).and_return(mock_console_logger(:update_attributes => false))
        put :update, :id => "1"
        assigns[:console_logger].should equal(mock_console_logger)
      end

      it "re-renders the 'edit' template" do
        Dataservice::ConsoleLogger.stub!(:find).and_return(mock_console_logger(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested console_logger" do
      Dataservice::ConsoleLogger.should_receive(:find).with("37").and_return(mock_console_logger)
      mock_console_logger.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the dataservice_console_loggers list" do
      Dataservice::ConsoleLogger.stub!(:find).and_return(mock_console_logger(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(dataservice_console_loggers_url)
    end
  end

end
