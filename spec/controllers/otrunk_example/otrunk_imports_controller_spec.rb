require File.expand_path('../../../spec_helper', __FILE__)

describe OtrunkExample::OtrunkImportsController do

  def mock_otrunk_import(stubs={})
    unless stubs.empty?
      stubs.each do |key, value|
        allow(@mock_otrunk_import).to receive(key).and_return(value)
      end
    end
    @mock_otrunk_import
  end
  
  before(:each) do
    generate_default_settings_and_jnlps_with_mocks
    generate_otrunk_example_with_mocks
    logout_user
  end
  
  describe "GET index" do

    it "exposes all otrunk_example_otrunk_imports as @otrunk_example_otrunk_imports" do
      expect(OtrunkExample::OtrunkImport).to receive(:all).and_return([mock_otrunk_import])
      get :index
      expect(assigns[:otrunk_example_otrunk_imports]).to eq([mock_otrunk_import])
    end

    describe "with mime type of xml" do
  
      it "renders all otrunk_example_otrunk_imports as xml" do
        expect(OtrunkExample::OtrunkImport).to receive(:all).and_return(otrunk_imports = double("Array of OtrunkExample::OtrunkImports"))
        expect(otrunk_imports).to receive(:to_xml).and_return("generated XML")
        get :index, :format => 'xml'
        expect(response.body).to eq("generated XML")
      end
    
    end

  end

  describe "GET show" do

    it "exposes the requested otrunk_import as @otrunk_import" do
      expect(OtrunkExample::OtrunkImport).to receive(:find).with("37").and_return(mock_otrunk_import)
      get :show, :id => "37"
      expect(assigns[:otrunk_import]).to equal(mock_otrunk_import)
    end
    
    describe "with mime type of xml" do

      it "renders the requested otrunk_import as xml" do
        expect(OtrunkExample::OtrunkImport).to receive(:find).with("37").and_return(mock_otrunk_import)
        expect(mock_otrunk_import).to receive(:to_xml).and_return("generated XML")
        get :show, :id => "37", :format => 'xml'
        expect(response.body).to eq("generated XML")
      end

    end
    
  end

  describe "GET new" do
  
    it "exposes a new otrunk_import as @otrunk_import" do
      expect(OtrunkExample::OtrunkImport).to receive(:new).and_return(mock_otrunk_import)
      get :new
      expect(assigns[:otrunk_import]).to equal(mock_otrunk_import)
    end

  end

  describe "GET edit" do
  
    it "exposes the requested otrunk_import as @otrunk_import" do
      expect(OtrunkExample::OtrunkImport).to receive(:find).with("37").and_return(mock_otrunk_import)
      get :edit, :id => "37"
      expect(assigns[:otrunk_import]).to equal(mock_otrunk_import)
    end

  end

  describe "POST create" do

    describe "with valid params" do
      
      it "exposes a newly created otrunk_import as @otrunk_import" do
        expect(OtrunkExample::OtrunkImport).to receive(:new).with({'these' => 'params'}).and_return(mock_otrunk_import(:save => true))
        post :create, :otrunk_import => {:these => 'params'}
        expect(assigns(:otrunk_import)).to equal(mock_otrunk_import)
      end

      it "redirects to the created otrunk_import" do
        allow(OtrunkExample::OtrunkImport).to receive(:new).and_return(mock_otrunk_import(:save => true))
        post :create, :otrunk_import => {}
        expect(response).to redirect_to(otrunk_example_otrunk_import_url(mock_otrunk_import))
      end
      
    end
    
    describe "with invalid params" do

      it "exposes a newly created but unsaved otrunk_import as @otrunk_import" do
        allow(OtrunkExample::OtrunkImport).to receive(:new).with({'these' => 'params'}).and_return(mock_otrunk_import(:save => false))
        post :create, :otrunk_import => {:these => 'params'}
        expect(assigns(:otrunk_import)).to equal(mock_otrunk_import)
      end

      it "re-renders the 'new' template" do
        allow(OtrunkExample::OtrunkImport).to receive(:new).and_return(mock_otrunk_import(:save => false))
        post :create, :otrunk_import => {}
        expect(response).to render_template('new')
      end
      
    end
    
  end

  describe "PUT udpate" do

    describe "with valid params" do

      it "updates the requested otrunk_import" do
        expect(OtrunkExample::OtrunkImport).to receive(:find).with("37").and_return(mock_otrunk_import)
        expect(mock_otrunk_import).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :otrunk_import => {:these => 'params'}
      end

      it "exposes the requested otrunk_import as @otrunk_import" do
        allow(OtrunkExample::OtrunkImport).to receive(:find).and_return(mock_otrunk_import(:update_attributes => true))
        put :update, :id => "1"
        expect(assigns(:otrunk_import)).to equal(mock_otrunk_import)
      end

      it "redirects to the otrunk_import" do
        allow(OtrunkExample::OtrunkImport).to receive(:find).and_return(mock_otrunk_import(:update_attributes => true))
        put :update, :id => "1"
        expect(response).to redirect_to(otrunk_example_otrunk_import_url(mock_otrunk_import))
      end

    end
    
    describe "with invalid params" do

      it "updates the requested otrunk_import" do
        expect(OtrunkExample::OtrunkImport).to receive(:find).with("37").and_return(mock_otrunk_import)
        expect(mock_otrunk_import).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :otrunk_import => {:these => 'params'}
      end

      it "exposes the otrunk_import as @otrunk_import" do
        allow(OtrunkExample::OtrunkImport).to receive(:find).and_return(mock_otrunk_import(:update_attributes => false))
        put :update, :id => "1"
        expect(assigns(:otrunk_import)).to equal(mock_otrunk_import)
      end

      it "re-renders the 'edit' template" do
        allow(OtrunkExample::OtrunkImport).to receive(:find).and_return(mock_otrunk_import(:update_attributes => false))
        put :update, :id => "1"
        expect(response).to render_template('edit')
      end

    end

  end

  describe "DELETE destroy" do

    it "destroys the requested otrunk_import" do
      expect(OtrunkExample::OtrunkImport).to receive(:find).with("37").and_return(mock_otrunk_import)
      expect(mock_otrunk_import).to receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "redirects to the otrunk_example_otrunk_imports list" do
      allow(OtrunkExample::OtrunkImport).to receive(:find).and_return(mock_otrunk_import(:destroy => true))
      delete :destroy, :id => "1"
      expect(response).to redirect_to(otrunk_example_otrunk_imports_url)
    end

  end

end
