require 'spec_helper'

describe MavenJnlp::VersionedJnlpsController do

  def mock_versioned_jnlp(stubs={})
    @mock_versioned_jnlp ||= mock_model(MavenJnlp::VersionedJnlp, stubs)
  end
  
  before(:each) do
    generate_default_project_and_jnlps_with_mocks
    logout_user
  end
  
  describe "GET index" do

    it "exposes all maven_jnlp_versioned_jnlps as @maven_jnlp_versioned_jnlps" do
      MavenJnlp::VersionedJnlp.should_receive(:find).with(:all).and_return([mock_versioned_jnlp])
      get :index
      assigns[:maven_jnlp_versioned_jnlps].should == [mock_versioned_jnlp]
    end

    describe "with mime type of xml" do
  
      it "renders all maven_jnlp_versioned_jnlps as xml" do
        MavenJnlp::VersionedJnlp.should_receive(:find).with(:all).and_return(versioned_jnlps = mock("Array of MavenJnlp::VersionedJnlps"))
        versioned_jnlps.should_receive(:to_xml).and_return("generated XML")
        get :index, :format => 'xml'
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "GET show" do
  
    it "exposes the requested versioned_jnlp as @versioned_jnlp" do
      MavenJnlp::VersionedJnlp.should_receive(:find).with("37").and_return(mock_versioned_jnlp)
      get :show, :id => "37"
      assigns[:versioned_jnlp].should equal(mock_versioned_jnlp)
    end
    
    describe "with mime type of xml" do
  
      it "renders the requested versioned_jnlp as xml" do
        MavenJnlp::VersionedJnlp.should_receive(:find).with("37").and_return(mock_versioned_jnlp)
        mock_versioned_jnlp.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37", :format => 'xml'
        response.body.should == "generated XML"
      end
  
    end
    
  end
  
  describe "GET new" do
  
    it "exposes a new versioned_jnlp as @versioned_jnlp" do
      MavenJnlp::VersionedJnlp.should_receive(:new).and_return(mock_versioned_jnlp)
      get :new
      assigns[:versioned_jnlp].should equal(mock_versioned_jnlp)
    end
  
  end
  
  describe "GET edit" do
  
    it "exposes the requested versioned_jnlp as @versioned_jnlp" do
      MavenJnlp::VersionedJnlp.should_receive(:find).with("37").and_return(mock_versioned_jnlp)
      get :edit, :id => "37"
      assigns[:versioned_jnlp].should equal(mock_versioned_jnlp)
    end
  
  end
  
  describe "POST create" do
  
    describe "with valid params" do
      
      it "exposes a newly created versioned_jnlp as @versioned_jnlp" do
        MavenJnlp::VersionedJnlp.should_receive(:new).with({'these' => 'params'}).and_return(mock_versioned_jnlp(:save => true))
        post :create, :versioned_jnlp => {:these => 'params'}
        assigns(:versioned_jnlp).should equal(mock_versioned_jnlp)
      end
  
      it "redirects to the created versioned_jnlp" do
        MavenJnlp::VersionedJnlp.stub!(:new).and_return(mock_versioned_jnlp(:save => true))
        post :create, :versioned_jnlp => {}
        response.should redirect_to(maven_jnlp_versioned_jnlp_url(mock_versioned_jnlp))
      end
      
    end
    
    describe "with invalid params" do
  
      it "exposes a newly created but unsaved versioned_jnlp as @versioned_jnlp" do
        MavenJnlp::VersionedJnlp.stub!(:new).with({'these' => 'params'}).and_return(mock_versioned_jnlp(:save => false))
        post :create, :versioned_jnlp => {:these => 'params'}
        assigns(:versioned_jnlp).should equal(mock_versioned_jnlp)
      end
  
      it "re-renders the 'new' template" do
        MavenJnlp::VersionedJnlp.stub!(:new).and_return(mock_versioned_jnlp(:save => false))
        post :create, :versioned_jnlp => {}
        response.should render_template('new')
      end
      
    end
    
  end
  
  describe "PUT udpate" do
  
    describe "with valid params" do
  
      it "updates the requested versioned_jnlp" do
        MavenJnlp::VersionedJnlp.should_receive(:find).with("37").and_return(mock_versioned_jnlp)
        mock_versioned_jnlp.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :versioned_jnlp => {:these => 'params'}
      end
  
      it "exposes the requested versioned_jnlp as @versioned_jnlp" do
        MavenJnlp::VersionedJnlp.stub!(:find).and_return(mock_versioned_jnlp(:update_attributes => true))
        put :update, :id => "1"
        assigns(:versioned_jnlp).should equal(mock_versioned_jnlp)
      end
  
      it "redirects to the versioned_jnlp" do
        MavenJnlp::VersionedJnlp.stub!(:find).and_return(mock_versioned_jnlp(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(maven_jnlp_versioned_jnlp_url(mock_versioned_jnlp))
      end
  
    end
    
    describe "with invalid params" do
  
      it "updates the requested versioned_jnlp" do
        MavenJnlp::VersionedJnlp.should_receive(:find).with("37").and_return(mock_versioned_jnlp)
        mock_versioned_jnlp.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :versioned_jnlp => {:these => 'params'}
      end
  
      it "exposes the versioned_jnlp as @versioned_jnlp" do
        MavenJnlp::VersionedJnlp.stub!(:find).and_return(mock_versioned_jnlp(:update_attributes => false))
        put :update, :id => "1"
        assigns(:versioned_jnlp).should equal(mock_versioned_jnlp)
      end
  
      it "re-renders the 'edit' template" do
        MavenJnlp::VersionedJnlp.stub!(:find).and_return(mock_versioned_jnlp(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
  
    end
  
  end
  
  describe "DELETE destroy" do
  
    it "destroys the requested versioned_jnlp" do
      MavenJnlp::VersionedJnlp.should_receive(:find).with("37").and_return(mock_versioned_jnlp)
      mock_versioned_jnlp.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "redirects to the maven_jnlp_versioned_jnlps list" do
      MavenJnlp::VersionedJnlp.stub!(:find).and_return(mock_versioned_jnlp(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(maven_jnlp_versioned_jnlps_url)
    end
  
  end

end
