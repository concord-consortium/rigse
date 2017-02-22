require File.expand_path('../../../spec_helper', __FILE__)

describe OtrunkExample::OtrunkViewEntriesController do

  def mock_otrunk_view_entry(stubs={})
    unless stubs.empty?
      stubs.each do |key, value|
        allow(@mock_otrunk_view_entry).to receive(key).and_return(value)
      end
    end
    @mock_otrunk_view_entry
  end
  
  before(:each) do
    generate_default_settings_and_jnlps_with_mocks
    generate_otrunk_example_with_mocks
    logout_user
  end
  
  describe "GET index" do

    it "exposes all otrunk_example_otrunk_view_entries as @otrunk_example_otrunk_view_entries" do
      expect(OtrunkExample::OtrunkViewEntry).to receive(:all).and_return([mock_otrunk_view_entry])
      get :index
      expect(assigns[:otrunk_example_otrunk_view_entries]).to eq([mock_otrunk_view_entry])
    end

    describe "with mime type of xml" do
  
      it "renders all otrunk_example_otrunk_view_entries as xml" do
        expect(OtrunkExample::OtrunkViewEntry).to receive(:all).and_return(otrunk_view_entries = double("Array of OtrunkExample::OtrunkViewEntries"))
        expect(otrunk_view_entries).to receive(:to_xml).and_return("generated XML")
        get :index, :format => 'xml'
        expect(response.body).to eq("generated XML")
      end
    
    end

  end

  describe "GET show" do

    it "exposes the requested otrunk_view_entry as @otrunk_view_entry" do
      expect(OtrunkExample::OtrunkViewEntry).to receive(:find).with("37").and_return(mock_otrunk_view_entry)
      get :show, :id => "37"
      expect(assigns[:otrunk_view_entry]).to equal(mock_otrunk_view_entry)
    end
    
    describe "with mime type of xml" do

      it "renders the requested otrunk_view_entry as xml" do
        expect(OtrunkExample::OtrunkViewEntry).to receive(:find).with("37").and_return(mock_otrunk_view_entry)
        expect(mock_otrunk_view_entry).to receive(:to_xml).and_return("generated XML")
        get :show, :id => "37", :format => 'xml'
        expect(response.body).to eq("generated XML")
      end

    end
    
  end

  describe "GET new" do
  
    it "exposes a new otrunk_view_entry as @otrunk_view_entry" do
      expect(OtrunkExample::OtrunkViewEntry).to receive(:new).and_return(mock_otrunk_view_entry)
      get :new
      expect(assigns[:otrunk_view_entry]).to equal(mock_otrunk_view_entry)
    end

  end

  describe "GET edit" do
  
    it "exposes the requested otrunk_view_entry as @otrunk_view_entry" do
      expect(OtrunkExample::OtrunkViewEntry).to receive(:find).with("37").and_return(mock_otrunk_view_entry)
      get :edit, :id => "37"
      expect(assigns[:otrunk_view_entry]).to equal(mock_otrunk_view_entry)
    end

  end

  describe "POST create" do

    describe "with valid params" do
      
      it "exposes a newly created otrunk_view_entry as @otrunk_view_entry" do
        expect(OtrunkExample::OtrunkViewEntry).to receive(:new).with({'these' => 'params'}).and_return(mock_otrunk_view_entry(:save => true))
        post :create, :otrunk_view_entry => {'these' => 'params'}
        expect(assigns(:otrunk_view_entry)).to equal(mock_otrunk_view_entry)
      end

      it "redirects to the created otrunk_view_entry" do
        allow(OtrunkExample::OtrunkViewEntry).to receive(:new).and_return(mock_otrunk_view_entry(:save => true))
        post :create, :otrunk_view_entry => {}
        expect(response).to redirect_to(otrunk_example_otrunk_view_entry_url(mock_otrunk_view_entry))
      end
      
    end
    
    describe "with invalid params" do

      it "exposes a newly created but unsaved otrunk_view_entry as @otrunk_view_entry" do
        allow(OtrunkExample::OtrunkViewEntry).to receive(:new).with({'these' => 'params'}).and_return(mock_otrunk_view_entry(:save => false))
        post :create, :otrunk_view_entry => {'these' => 'params'}
        expect(assigns(:otrunk_view_entry)).to equal(mock_otrunk_view_entry)
      end

      it "re-renders the 'new' template" do
        allow(OtrunkExample::OtrunkViewEntry).to receive(:new).and_return(mock_otrunk_view_entry(:save => false))
        post :create, :otrunk_view_entry => {}
        expect(response).to render_template('new')
      end
      
    end
    
  end

  describe "PUT udpate" do

    describe "with valid params" do

      it "updates the requested otrunk_view_entry" do
        expect(OtrunkExample::OtrunkViewEntry).to receive(:find).with("37").and_return(mock_otrunk_view_entry)
        expect(mock_otrunk_view_entry).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :otrunk_view_entry => {'these' => 'params'}
      end

      it "exposes the requested otrunk_view_entry as @otrunk_view_entry" do
        allow(OtrunkExample::OtrunkViewEntry).to receive(:find).and_return(mock_otrunk_view_entry(:update_attributes => true))
        put :update, :id => "1"
        expect(assigns(:otrunk_view_entry)).to equal(mock_otrunk_view_entry)
      end

      it "redirects to the otrunk_view_entry" do
        allow(OtrunkExample::OtrunkViewEntry).to receive(:find).and_return(mock_otrunk_view_entry(:update_attributes => true))
        put :update, :id => "1"
        expect(response).to redirect_to(otrunk_example_otrunk_view_entry_url(mock_otrunk_view_entry))
      end

    end
    
    describe "with invalid params" do

      it "updates the requested otrunk_view_entry" do
        expect(OtrunkExample::OtrunkViewEntry).to receive(:find).with("37").and_return(mock_otrunk_view_entry)
        expect(mock_otrunk_view_entry).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :otrunk_view_entry => {'these' => 'params'}
      end

      it "exposes the otrunk_view_entry as @otrunk_view_entry" do
        allow(OtrunkExample::OtrunkViewEntry).to receive(:find).and_return(mock_otrunk_view_entry(:update_attributes => false))
        put :update, :id => "1"
        expect(assigns(:otrunk_view_entry)).to equal(mock_otrunk_view_entry)
      end

      it "re-renders the 'edit' template" do
        allow(OtrunkExample::OtrunkViewEntry).to receive(:find).and_return(mock_otrunk_view_entry(:update_attributes => false))
        put :update, :id => "1"
        expect(response).to render_template('edit')
      end

    end

  end

  describe "DELETE destroy" do

    it "destroys the requested otrunk_view_entry" do
      expect(OtrunkExample::OtrunkViewEntry).to receive(:find).with("37").and_return(mock_otrunk_view_entry)
      expect(mock_otrunk_view_entry).to receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "redirects to the otrunk_example_otrunk_view_entries list" do
      allow(OtrunkExample::OtrunkViewEntry).to receive(:find).and_return(mock_otrunk_view_entry(:destroy => true))
      delete :destroy, :id => "1"
      expect(response).to redirect_to(otrunk_example_otrunk_view_entries_url)
    end

  end

end
