require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ActivitiesController do

  def mock_investigation(stubs={})
    @mock_investigation ||= mock_model(Investigation, stubs)
  end
  
  describe "responding to GET index" do

    it "should expose all investigations as @investigations" do
      Investigation.should_receive(:find).with(:all).and_return([mock_investigation])
      get :index
      assigns[:investigations].should == [mock_investigation]
    end

    describe "with mime type of xml" do
  
      it "should render all investigations as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Investigation.should_receive(:find).with(:all).and_return(investigations = mock("Array of Activities"))
        investigations.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested investigation as @investigation" do
      Investigation.should_receive(:find).with("37").and_return(mock_investigation)
      get :show, :id => "37"
      assigns[:investigation].should equal(mock_investigation)
    end
    
    describe "with mime type of xml" do

      it "should render the requested investigation as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Investigation.should_receive(:find).with("37").and_return(mock_investigation)
        mock_investigation.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new investigation as @investigation" do
      Investigation.should_receive(:new).and_return(mock_investigation)
      get :new
      assigns[:investigation].should equal(mock_investigation)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested investigation as @investigation" do
      Investigation.should_receive(:find).with("37").and_return(mock_investigation)
      get :edit, :id => "37"
      assigns[:investigation].should equal(mock_investigation)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created investigation as @investigation" do
        Investigation.should_receive(:new).with({'these' => 'params'}).and_return(mock_investigation(:save => true))
        post :create, :investigation => {:these => 'params'}
        assigns(:investigation).should equal(mock_investigation)
      end

      it "should redirect to the created investigation" do
        Investigation.stub!(:new).and_return(mock_investigation(:save => true))
        post :create, :investigation => {}
        response.should redirect_to(investigation_url(mock_investigation))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved investigation as @investigation" do
        Investigation.stub!(:new).with({'these' => 'params'}).and_return(mock_investigation(:save => false))
        post :create, :investigation => {:these => 'params'}
        assigns(:investigation).should equal(mock_investigation)
      end

      it "should re-render the 'new' template" do
        Investigation.stub!(:new).and_return(mock_investigation(:save => false))
        post :create, :investigation => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested investigation" do
        Investigation.should_receive(:find).with("37").and_return(mock_investigation)
        mock_investigation.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :investigation => {:these => 'params'}
      end

      it "should expose the requested investigation as @investigation" do
        Investigation.stub!(:find).and_return(mock_investigation(:update_attributes => true))
        put :update, :id => "1"
        assigns(:investigation).should equal(mock_investigation)
      end

      it "should redirect to the investigation" do
        Investigation.stub!(:find).and_return(mock_investigation(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(investigation_url(mock_investigation))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested investigation" do
        Investigation.should_receive(:find).with("37").and_return(mock_investigation)
        mock_investigation.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :investigation => {:these => 'params'}
      end

      it "should expose the investigation as @investigation" do
        Investigation.stub!(:find).and_return(mock_investigation(:update_attributes => false))
        put :update, :id => "1"
        assigns(:investigation).should equal(mock_investigation)
      end

      it "should re-render the 'edit' template" do
        Investigation.stub!(:find).and_return(mock_investigation(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested investigation" do
      Investigation.should_receive(:find).with("37").and_return(mock_investigation)
      mock_investigation.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the investigations list" do
      Investigation.stub!(:find).and_return(mock_investigation(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(investigations_url)
    end

  end

end
