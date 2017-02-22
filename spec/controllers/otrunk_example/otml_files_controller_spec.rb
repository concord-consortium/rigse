require File.expand_path('../../../spec_helper', __FILE__)

describe OtrunkExample::OtmlFilesController do

  def mock_otml_file(stubs={})
    unless stubs.empty?
      stubs.each do |key, value|
        allow(@mock_otml_file).to receive(key).and_return(value)
      end
    end
    @mock_otml_file
  end
  
  before(:each) do
    generate_default_settings_and_jnlps_with_mocks
    generate_otrunk_example_with_mocks
    logout_user
  end
  
  describe "GET index" do

    it "exposes all otrunk_example_otml_files as @otrunk_example_otml_files" do
      expect(OtrunkExample::OtmlFile).to receive(:all).and_return([mock_otml_file])
      get :index
      expect(assigns[:otrunk_example_otml_files]).to eq([mock_otml_file])
    end

    describe "with mime type of xml" do
  
      it "renders all otrunk_example_otml_files as xml" do
        expect(OtrunkExample::OtmlFile).to receive(:all).and_return(otml_files = double("Array of OtrunkExample::OtmlFiles"))
        expect(otml_files).to receive(:to_xml).and_return("generated XML")
        get :index, :format => 'xml'
        expect(response.body).to eq("generated XML")
      end
    
    end

  end

  describe "GET show" do

    it "exposes the requested otml_file as @otml_file" do
      expect(OtrunkExample::OtmlFile).to receive(:find).with("37").and_return(mock_otml_file)
      get :show, :id => "37"
      expect(assigns[:otml_file]).to equal(mock_otml_file)
    end
    
    describe "with mime type of xml" do

      it "renders the requested otml_file as xml" do
        expect(OtrunkExample::OtmlFile).to receive(:find).with("37").and_return(mock_otml_file)
        expect(mock_otml_file).to receive(:to_xml).and_return("generated XML")
        get :show, :id => "37", :format => 'xml'
        expect(response.body).to eq("generated XML")
      end

    end
    
  end

  describe "GET new" do
  
    it "exposes a new otml_file as @otml_file" do
      expect(OtrunkExample::OtmlFile).to receive(:new).and_return(mock_otml_file)
      get :new
      expect(assigns[:otml_file]).to equal(mock_otml_file)
    end

  end

  describe "GET edit" do
  
    it "exposes the requested otml_file as @otml_file" do
      expect(OtrunkExample::OtmlFile).to receive(:find).with("37").and_return(mock_otml_file)
      get :edit, :id => "37"
      expect(assigns[:otml_file]).to equal(mock_otml_file)
    end

  end

  describe "POST create" do

    describe "with valid params" do
      
      it "exposes a newly created otml_file as @otml_file" do
        expect(OtrunkExample::OtmlFile).to receive(:new).with({'these' => 'params'}).and_return(mock_otml_file(:save => true))
        post :create, :otml_file => {:these => 'params'}
        expect(assigns(:otml_file)).to equal(mock_otml_file)
      end

      it "redirects to the created otml_file" do
        allow(OtrunkExample::OtmlFile).to receive(:new).and_return(mock_otml_file(:save => true))
        post :create, :otml_file => {}
        expect(response).to redirect_to(otrunk_example_otml_file_url(mock_otml_file))
      end
      
    end
    
    describe "with invalid params" do

      it "exposes a newly created but unsaved otml_file as @otml_file" do
        allow(OtrunkExample::OtmlFile).to receive(:new).with({'these' => 'params'}).and_return(mock_otml_file(:save => false))
        post :create, :otml_file => {:these => 'params'}
        expect(assigns(:otml_file)).to equal(mock_otml_file)
      end

      it "re-renders the 'new' template" do
        allow(OtrunkExample::OtmlFile).to receive(:new).and_return(mock_otml_file(:save => false))
        post :create, :otml_file => {}
        expect(response).to render_template('new')
      end
      
    end
    
  end

  describe "PUT udpate" do

    describe "with valid params" do

      it "updates the requested otml_file" do
        expect(OtrunkExample::OtmlFile).to receive(:find).with("37").and_return(mock_otml_file)
        expect(mock_otml_file).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :otml_file => {:these => 'params'}
      end

      it "exposes the requested otml_file as @otml_file" do
        allow(OtrunkExample::OtmlFile).to receive(:find).and_return(mock_otml_file(:update_attributes => true))
        put :update, :id => "1"
        expect(assigns(:otml_file)).to equal(mock_otml_file)
      end

      it "redirects to the otml_file" do
        allow(OtrunkExample::OtmlFile).to receive(:find).and_return(mock_otml_file(:update_attributes => true))
        put :update, :id => "1"
        expect(response).to redirect_to(otrunk_example_otml_file_url(mock_otml_file))
      end

    end
    
    describe "with invalid params" do

      it "updates the requested otml_file" do
        expect(OtrunkExample::OtmlFile).to receive(:find).with("37").and_return(mock_otml_file)
        expect(mock_otml_file).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :otml_file => {:these => 'params'}
      end

      it "exposes the otml_file as @otml_file" do
        allow(OtrunkExample::OtmlFile).to receive(:find).and_return(mock_otml_file(:update_attributes => false))
        put :update, :id => "1"
        expect(assigns(:otml_file)).to equal(mock_otml_file)
      end

      it "re-renders the 'edit' template" do
        allow(OtrunkExample::OtmlFile).to receive(:find).and_return(mock_otml_file(:update_attributes => false))
        put :update, :id => "1"
        expect(response).to render_template('edit')
      end

    end

  end

  describe "DELETE destroy" do

    it "destroys the requested otml_file" do
      expect(OtrunkExample::OtmlFile).to receive(:find).with("37").and_return(mock_otml_file)
      expect(mock_otml_file).to receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "redirects to the otrunk_example_otml_files list" do
      allow(OtrunkExample::OtmlFile).to receive(:find).and_return(mock_otml_file(:destroy => true))
      delete :destroy, :id => "1"
      expect(response).to redirect_to(otrunk_example_otml_files_url)
    end

  end

end
