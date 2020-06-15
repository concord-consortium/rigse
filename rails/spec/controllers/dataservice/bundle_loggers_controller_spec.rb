require File.expand_path('../../../spec_helper', __FILE__)

describe Dataservice::BundleLoggersController do

  def mock_bundle_content(stubs={})
    stubs[:eportfolio] = Dataservice::BundleContent::EMPTY_EPORTFOLIO_BUNDLE
    @mock_bundle_content ||= mock_model(Dataservice::BundleContent, stubs)
  end

  def mock_bundle_logger(stubs={})
    stubs[:last_non_empty_bundle_content] = mock_bundle_content
    @mock_bundle_logger ||= mock_model(Dataservice::BundleLogger, stubs)
  end

  describe "GET index" do
    it "assigns all dataservice_bundle_loggers as @dataservice_bundle_loggers" do
      expect(Dataservice::BundleLogger).to receive(:search).with(nil, nil, nil).and_return([mock_bundle_logger])
      login_admin
      get :index
      expect(assigns[:dataservice_bundle_loggers]).to eq([mock_bundle_logger])
    end
  end

  describe "GET show" do
    it "assigns the requested bundle_logger as @dataservice_bundle_logger" do
      logger = mock_bundle_logger
      expect(Dataservice::BundleLogger).to receive(:find).with("37").and_return(logger)
      expect(logger).to receive(:in_progress_bundle).twice.and_return(mock_bundle_content)
      login_admin
      get :show, :id => "37"
      expect(assigns[:dataservice_bundle_logger]).to equal(mock_bundle_logger)
    end
  end

  describe "GET new" do
    it "assigns a new bundle_logger as @dataservice_bundle_logger" do
      expect(Dataservice::BundleLogger).to receive(:new).and_return(mock_bundle_logger)
      login_admin
      get :new
      expect(assigns[:dataservice_bundle_logger]).to equal(mock_bundle_logger)
    end
  end

  describe "GET edit" do
    it "assigns the requested bundle_logger as @dataservice_bundle_logger" do
      expect(Dataservice::BundleLogger).to receive(:find).with("37").and_return(mock_bundle_logger)
      login_admin
      get :edit, :id => "37"
      expect(assigns[:dataservice_bundle_logger]).to equal(mock_bundle_logger)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created bundle_logger as @dataservice_bundle_logger" do
        expect(Dataservice::BundleLogger).to receive(:new).with({'these' => 'params'}).and_return(mock_bundle_logger(:save => true))
        login_admin
        post :create, :dataservice_bundle_logger => {:these => 'params'}
        expect(assigns[:dataservice_bundle_logger]).to equal(mock_bundle_logger)
      end

      it "redirects to the created bundle_logger" do
        expect(Dataservice::BundleLogger).to receive(:new).and_return(mock_bundle_logger(:save => true))
        login_admin
        post :create, :dataservice_bundle_logger => {}
        expect(response).to redirect_to(dataservice_bundle_logger_url(mock_bundle_logger))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved bundle_logger as @dataservice_bundle_logger" do
        expect(Dataservice::BundleLogger).to receive(:new).with({'these' => 'params'}).and_return(mock_bundle_logger(:save => false))
        login_admin
        post :create, :dataservice_bundle_logger => {:these => 'params'}
        expect(assigns[:dataservice_bundle_logger]).to equal(mock_bundle_logger)
      end

      it "re-renders the 'new' template" do
        expect(Dataservice::BundleLogger).to receive(:new).and_return(mock_bundle_logger(:save => false))
        login_admin
        post :create, :dataservice_bundle_logger => {}
        expect(response).to render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested bundle_logger" do
        expect(Dataservice::BundleLogger).to receive(:find).with("37").and_return(mock_bundle_logger)
        expect(mock_bundle_logger).to receive(:update_attributes).with({'these' => 'params'})
        login_admin
        put :update, :id => "37", :dataservice_bundle_logger => {:these => 'params'}
      end

      it "assigns the requested bundle_logger as @dataservice_bundle_logger" do
        expect(Dataservice::BundleLogger).to receive(:find).and_return(mock_bundle_logger(:update_attributes => true))
        login_admin
        put :update, :id => "1"
        expect(assigns[:dataservice_bundle_logger]).to equal(mock_bundle_logger)
      end

      it "redirects to the bundle_logger" do
        expect(Dataservice::BundleLogger).to receive(:find).and_return(mock_bundle_logger(:update_attributes => true))
        login_admin
        put :update, :id => "1"
        expect(response).to redirect_to(dataservice_bundle_logger_url(mock_bundle_logger))
      end
    end

    describe "with invalid params" do
      it "updates the requested bundle_logger" do
        expect(Dataservice::BundleLogger).to receive(:find).with("37").and_return(mock_bundle_logger)
        expect(mock_bundle_logger).to receive(:update_attributes).with({'these' => 'params'})
        login_admin
        put :update, :id => "37", :dataservice_bundle_logger => {:these => 'params'}
      end

      it "assigns the bundle_logger as @dataservice_bundle_logger" do
        expect(Dataservice::BundleLogger).to receive(:find).and_return(mock_bundle_logger(:update_attributes => false))
        login_admin
        put :update, :id => "1"
        expect(assigns[:dataservice_bundle_logger]).to equal(mock_bundle_logger)
      end

      it "re-renders the 'edit' template" do
        expect(Dataservice::BundleLogger).to receive(:find).and_return(mock_bundle_logger(:update_attributes => false))
        login_admin
        put :update, :id => "1"
        expect(response).to render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested bundle_logger" do
      expect(Dataservice::BundleLogger).to receive(:find).with("37").and_return(mock_bundle_logger)
      expect(mock_bundle_logger).to receive(:destroy)
      login_admin
      delete :destroy, :id => "37"
    end

    it "redirects to the dataservice_bundle_loggers list" do
      expect(Dataservice::BundleLogger).to receive(:find).and_return(mock_bundle_logger(:destroy => true))
      login_admin
      delete :destroy, :id => "1"
      expect(response).to redirect_to(dataservice_bundle_loggers_url)
    end
  end
end
