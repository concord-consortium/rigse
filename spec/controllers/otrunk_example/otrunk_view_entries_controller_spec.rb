require File.expand_path('../../../spec_helper', __FILE__)

describe OtrunkExample::OtrunkViewEntriesController do

  def mock_otrunk_view_entry(stubs={})
    @mock_otrunk_view_entry.stub!(stubs) unless stubs.empty?
    @mock_otrunk_view_entry
  end
  
  before(:each) do
    generate_default_project_and_jnlps_with_mocks
    generate_otrunk_example_with_mocks
    logout_user
  end
  
  describe "GET index" do

    it "exposes all otrunk_example_otrunk_view_entries as @otrunk_example_otrunk_view_entries" do
      OtrunkExample::OtrunkViewEntry.should_receive(:find).with(:all).and_return([mock_otrunk_view_entry])
      get :index
      assigns[:otrunk_example_otrunk_view_entries].should == [mock_otrunk_view_entry]
    end

    describe "with mime type of xml" do
  
      it "renders all otrunk_example_otrunk_view_entries as xml" do
        OtrunkExample::OtrunkViewEntry.should_receive(:find).with(:all).and_return(otrunk_view_entries = mock("Array of OtrunkExample::OtrunkViewEntries"))
        otrunk_view_entries.should_receive(:to_xml).and_return("generated XML")
        get :index, :format => 'xml'
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "GET show" do

    it "exposes the requested otrunk_view_entry as @otrunk_view_entry" do
      OtrunkExample::OtrunkViewEntry.should_receive(:find).with("37").and_return(mock_otrunk_view_entry)
      get :show, :id => "37"
      assigns[:otrunk_view_entry].should equal(mock_otrunk_view_entry)
    end
    
    describe "with mime type of xml" do

      it "renders the requested otrunk_view_entry as xml" do
        OtrunkExample::OtrunkViewEntry.should_receive(:find).with("37").and_return(mock_otrunk_view_entry)
        mock_otrunk_view_entry.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37", :format => 'xml'
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "GET new" do
  
    it "exposes a new otrunk_view_entry as @otrunk_view_entry" do
      OtrunkExample::OtrunkViewEntry.should_receive(:new).and_return(mock_otrunk_view_entry)
      get :new
      assigns[:otrunk_view_entry].should equal(mock_otrunk_view_entry)
    end

  end

  describe "GET edit" do
  
    it "exposes the requested otrunk_view_entry as @otrunk_view_entry" do
      OtrunkExample::OtrunkViewEntry.should_receive(:find).with("37").and_return(mock_otrunk_view_entry)
      get :edit, :id => "37"
      assigns[:otrunk_view_entry].should equal(mock_otrunk_view_entry)
    end

  end

  describe "POST create" do

    describe "with valid params" do
      
      it "exposes a newly created otrunk_view_entry as @otrunk_view_entry" do
        OtrunkExample::OtrunkViewEntry.should_receive(:new).with({'these' => 'params'}).and_return(mock_otrunk_view_entry(:save => true))
        post :create, :otrunk_view_entry => {'these' => 'params'}
        assigns(:otrunk_view_entry).should equal(mock_otrunk_view_entry)
      end

      it "redirects to the created otrunk_view_entry" do
        OtrunkExample::OtrunkViewEntry.stub!(:new).and_return(mock_otrunk_view_entry(:save => true))
        post :create, :otrunk_view_entry => {}
        response.should redirect_to(otrunk_example_otrunk_view_entry_url(mock_otrunk_view_entry))
      end
      
    end
    
    describe "with invalid params" do

      it "exposes a newly created but unsaved otrunk_view_entry as @otrunk_view_entry" do
        OtrunkExample::OtrunkViewEntry.stub!(:new).with({'these' => 'params'}).and_return(mock_otrunk_view_entry(:save => false))
        post :create, :otrunk_view_entry => {'these' => 'params'}
        assigns(:otrunk_view_entry).should equal(mock_otrunk_view_entry)
      end

      it "re-renders the 'new' template" do
        OtrunkExample::OtrunkViewEntry.stub!(:new).and_return(mock_otrunk_view_entry(:save => false))
        post :create, :otrunk_view_entry => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "PUT udpate" do

    describe "with valid params" do

      it "updates the requested otrunk_view_entry" do
        OtrunkExample::OtrunkViewEntry.should_receive(:find).with("37").and_return(mock_otrunk_view_entry)
        mock_otrunk_view_entry.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :otrunk_view_entry => {'these' => 'params'}
      end

      it "exposes the requested otrunk_view_entry as @otrunk_view_entry" do
        OtrunkExample::OtrunkViewEntry.stub!(:find).and_return(mock_otrunk_view_entry(:update_attributes => true))
        put :update, :id => "1"
        assigns(:otrunk_view_entry).should equal(mock_otrunk_view_entry)
      end

      it "redirects to the otrunk_view_entry" do
        OtrunkExample::OtrunkViewEntry.stub!(:find).and_return(mock_otrunk_view_entry(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(otrunk_example_otrunk_view_entry_url(mock_otrunk_view_entry))
      end

    end
    
    describe "with invalid params" do

      it "updates the requested otrunk_view_entry" do
        OtrunkExample::OtrunkViewEntry.should_receive(:find).with("37").and_return(mock_otrunk_view_entry)
        mock_otrunk_view_entry.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :otrunk_view_entry => {'these' => 'params'}
      end

      it "exposes the otrunk_view_entry as @otrunk_view_entry" do
        OtrunkExample::OtrunkViewEntry.stub!(:find).and_return(mock_otrunk_view_entry(:update_attributes => false))
        put :update, :id => "1"
        assigns(:otrunk_view_entry).should equal(mock_otrunk_view_entry)
      end

      it "re-renders the 'edit' template" do
        OtrunkExample::OtrunkViewEntry.stub!(:find).and_return(mock_otrunk_view_entry(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "DELETE destroy" do

    it "destroys the requested otrunk_view_entry" do
      OtrunkExample::OtrunkViewEntry.should_receive(:find).with("37").and_return(mock_otrunk_view_entry)
      mock_otrunk_view_entry.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "redirects to the otrunk_example_otrunk_view_entries list" do
      OtrunkExample::OtrunkViewEntry.stub!(:find).and_return(mock_otrunk_view_entry(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(otrunk_example_otrunk_view_entries_url)
    end

  end

end
