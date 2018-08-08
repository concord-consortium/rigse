require File.expand_path('../../../spec_helper', __FILE__)

describe Dataservice::ConsoleLoggersController do

  def mock_console_content(stubs={})
    stubs[:eportfolio] = Dataservice::ConsoleContent::EMPTY_EPORTFOLIO_BUNDLE
    @mock_console_content ||= mock_model(Dataservice::ConsoleContent, stubs)
  end

  def mock_console_logger(stubs={})
    stubs[:last_console_content] = mock_console_content
    @mock_console_logger ||= mock_model(Dataservice::ConsoleLogger, stubs)
  end

  describe "GET index" do
    it "assigns all dataservice_console_loggers as @dataservice_console_loggers" do
      expect(Dataservice::ConsoleLogger).to receive(:search).with(nil, nil, nil).and_return([mock_console_logger])
      login_admin
      get :index
      expect(assigns[:dataservice_console_loggers]).to eq([mock_console_logger])
    end
  end

  describe "GET show" do
    it "assigns the requested console_logger as @dataservice_console_logger" do
      expect(Dataservice::ConsoleLogger).to receive(:find).with("37").and_return(mock_console_logger)
      login_admin
      get :show, :id => "37"
      expect(assigns[:dataservice_console_logger]).to equal(mock_console_logger)
    end
  end

  describe "GET new" do
    it "assigns a new console_logger as @dataservice_console_logger" do
      expect(Dataservice::ConsoleLogger).to receive(:new).and_return(mock_console_logger)
      login_admin
      get :new
      expect(assigns[:dataservice_console_logger]).to equal(mock_console_logger)
    end
  end

  describe "GET edit" do
    it "assigns the requested console_logger as @dataservice_console_logger" do
      expect(Dataservice::ConsoleLogger).to receive(:find).with("37").and_return(mock_console_logger)
      login_admin
      get :edit, :id => "37"
      expect(assigns[:dataservice_console_logger]).to equal(mock_console_logger)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created console_logger as @dataservice_console_logger" do
        expect(Dataservice::ConsoleLogger).to receive(:new).with({'these' => 'params'}).and_return(mock_console_logger(:save => true))
        login_admin
        post :create, :dataservice_console_logger => {:these => 'params'}
        expect(assigns[:dataservice_console_logger]).to equal(mock_console_logger)
      end

      it "redirects to the created console_logger" do
        expect(Dataservice::ConsoleLogger).to receive(:new).and_return(mock_console_logger(:save => true))
        login_admin
        post :create, :dataservice_console_logger => {}
        expect(response).to redirect_to(dataservice_console_logger_url(mock_console_logger))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved console_logger as @dataservice_console_logger" do
        expect(Dataservice::ConsoleLogger).to receive(:new).with({'these' => 'params'}).and_return(mock_console_logger(:save => false))
        login_admin
        post :create, :dataservice_console_logger => {:these => 'params'}
        expect(assigns[:dataservice_console_logger]).to equal(mock_console_logger)
      end

      it "re-renders the 'new' template" do
        expect(Dataservice::ConsoleLogger).to receive(:new).and_return(mock_console_logger(:save => false))
        login_admin
        post :create, :dataservice_console_logger => {}
        expect(response).to render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested console_logger" do
        expect(Dataservice::ConsoleLogger).to receive(:find).with("37").and_return(mock_console_logger)
        expect(mock_console_logger).to receive(:update_attributes).with({'these' => 'params'})
        login_admin
        put :update, :id => "37", :dataservice_console_logger => {:these => 'params'}
      end

      it "assigns the requested console_logger as @dataservice_console_logger" do
        expect(Dataservice::ConsoleLogger).to receive(:find).and_return(mock_console_logger(:update_attributes => true))
        login_admin
        put :update, :id => "1"
        expect(assigns[:dataservice_console_logger]).to equal(mock_console_logger)
      end

      it "redirects to the console_logger" do
        expect(Dataservice::ConsoleLogger).to receive(:find).and_return(mock_console_logger(:update_attributes => true))
        login_admin
        put :update, :id => "1"
        expect(response).to redirect_to(dataservice_console_logger_url(mock_console_logger))
      end
    end

    describe "with invalid params" do
      it "updates the requested console_logger" do
        expect(Dataservice::ConsoleLogger).to receive(:find).with("37").and_return(mock_console_logger)
        expect(mock_console_logger).to receive(:update_attributes).with({'these' => 'params'})
        login_admin
        put :update, :id => "37", :dataservice_console_logger => {:these => 'params'}
      end

      it "assigns the console_logger as @dataservice_console_logger" do
        expect(Dataservice::ConsoleLogger).to receive(:find).and_return(mock_console_logger(:update_attributes => false))
        login_admin
        put :update, :id => "1"
        expect(assigns[:dataservice_console_logger]).to equal(mock_console_logger)
      end

      it "re-renders the 'edit' template" do
        expect(Dataservice::ConsoleLogger).to receive(:find).and_return(mock_console_logger(:update_attributes => false))
        login_admin
        put :update, :id => "1"
        expect(response).to render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested console_logger" do
      expect(Dataservice::ConsoleLogger).to receive(:find).with("37").and_return(mock_console_logger)
      expect(mock_console_logger).to receive(:destroy)
      login_admin
      delete :destroy, :id => "37"
    end

    it "redirects to the dataservice_console_loggers list" do
      expect(Dataservice::ConsoleLogger).to receive(:find).and_return(mock_console_logger(:destroy => true))
      login_admin
      delete :destroy, :id => "1"
      expect(response).to redirect_to(dataservice_console_loggers_url)
    end
  end

end
