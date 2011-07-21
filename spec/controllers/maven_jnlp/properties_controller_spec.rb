require File.expand_path('../../../spec_helper', __FILE__)

describe MavenJnlp::PropertiesController do

  def mock_property(stubs={})
    @mock_property ||= mock_model(MavenJnlp::Property, stubs)
  end

  before(:each) do
    generate_default_project_and_jnlps_with_mocks
    logout_user
  end

  describe "GET index" do

    it "exposes all maven_jnlp_properties as @maven_jnlp_properties" do
      MavenJnlp::Property.should_receive(:find).with(:all).and_return([mock_property])
      get :index
      assigns[:maven_jnlp_properties].should == [mock_property]
    end

    describe "with mime type of xml" do
  
      it "renders all maven_jnlp_properties as xml" do
        MavenJnlp::Property.should_receive(:find).with(:all).and_return(properties = mock("Array of MavenJnlp::Properties"))
        properties.should_receive(:to_xml).and_return("generated XML")
        get :index, :format => 'xml'
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "GET show" do

    it "exposes the requested property as @property" do
      MavenJnlp::Property.should_receive(:find).with("37").and_return(mock_property)
      get :show, :id => "37"
      assigns[:property].should equal(mock_property)
    end
    
    describe "with mime type of xml" do

      it "renders the requested property as xml" do
        MavenJnlp::Property.should_receive(:find).with("37").and_return(mock_property)
        mock_property.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37", :format => 'xml'
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "GET new" do
  
    it "exposes a new property as @property" do
      MavenJnlp::Property.should_receive(:new).and_return(mock_property)
      get :new
      assigns[:property].should equal(mock_property)
    end

  end

  describe "GET edit" do
  
    it "exposes the requested property as @property" do
      MavenJnlp::Property.should_receive(:find).with("37").and_return(mock_property)
      get :edit, :id => "37"
      assigns[:property].should equal(mock_property)
    end

  end

  describe "POST create" do

    describe "with valid params" do
      
      it "exposes a newly created property as @property" do
        MavenJnlp::Property.should_receive(:new).with({'these' => 'params'}).and_return(mock_property(:save => true))
        post :create, :property => {:these => 'params'}
        assigns(:property).should equal(mock_property)
      end

      it "redirects to the created property" do
        MavenJnlp::Property.stub!(:new).and_return(mock_property(:save => true))
        post :create, :property => {}
        response.should redirect_to(maven_jnlp_property_url(mock_property))
      end
      
    end
    
    describe "with invalid params" do

      it "exposes a newly created but unsaved property as @property" do
        MavenJnlp::Property.stub!(:new).with({'these' => 'params'}).and_return(mock_property(:save => false))
        post :create, :property => {:these => 'params'}
        assigns(:property).should equal(mock_property)
      end

      it "re-renders the 'new' template" do
        MavenJnlp::Property.stub!(:new).and_return(mock_property(:save => false))
        post :create, :property => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "PUT udpate" do

    describe "with valid params" do

      it "updates the requested property" do
        MavenJnlp::Property.should_receive(:find).with("37").and_return(mock_property)
        mock_property.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :property => {:these => 'params'}
      end

      it "exposes the requested property as @property" do
        MavenJnlp::Property.stub!(:find).and_return(mock_property(:update_attributes => true))
        put :update, :id => "1"
        assigns(:property).should equal(mock_property)
      end

      it "redirects to the property" do
        MavenJnlp::Property.stub!(:find).and_return(mock_property(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(maven_jnlp_property_url(mock_property))
      end

    end
    
    describe "with invalid params" do

      it "updates the requested property" do
        MavenJnlp::Property.should_receive(:find).with("37").and_return(mock_property)
        mock_property.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :property => {:these => 'params'}
      end

      it "exposes the property as @property" do
        MavenJnlp::Property.stub!(:find).and_return(mock_property(:update_attributes => false))
        put :update, :id => "1"
        assigns(:property).should equal(mock_property)
      end

      it "re-renders the 'edit' template" do
        MavenJnlp::Property.stub!(:find).and_return(mock_property(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "DELETE destroy" do

    it "destroys the requested property" do
      MavenJnlp::Property.should_receive(:find).with("37").and_return(mock_property)
      mock_property.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "redirects to the maven_jnlp_properties list" do
      MavenJnlp::Property.stub!(:find).and_return(mock_property(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(maven_jnlp_properties_url)
    end

  end

end
