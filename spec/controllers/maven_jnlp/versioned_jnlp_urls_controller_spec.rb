require File.expand_path('../../../spec_helper', __FILE__)

describe MavenJnlp::VersionedJnlpUrlsController do

  def mock_versioned_jnlp_url(stubs={})
    @mock_versioned_jnlp_url ||= mock_model(MavenJnlp::VersionedJnlpUrl, stubs)
  end

  before(:each) do
    generate_default_project_and_jnlps_with_mocks
    logout_user
  end
  
  describe "GET index" do

    it "exposes all maven_jnlp_versioned_jnlp_urls as @maven_jnlp_versioned_jnlp_urls" do
      MavenJnlp::VersionedJnlpUrl.should_receive(:find).with(:all).and_return([mock_versioned_jnlp_url])
      get :index
      assigns[:maven_jnlp_versioned_jnlp_urls].should == [mock_versioned_jnlp_url]
    end

    describe "with mime type of xml" do
  
      it "renders all maven_jnlp_versioned_jnlp_urls as xml" do
        MavenJnlp::VersionedJnlpUrl.should_receive(:find).with(:all).and_return(versioned_jnlp_urls = mock("Array of MavenJnlp::VersionedJnlpUrls"))
        versioned_jnlp_urls.should_receive(:to_xml).and_return("generated XML")
        get :index, :format => 'xml'
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "GET show" do

    it "exposes the requested versioned_jnlp_url as @versioned_jnlp_url" do
      MavenJnlp::VersionedJnlpUrl.should_receive(:find).with("37").and_return(mock_versioned_jnlp_url)
      get :show, :id => "37"
      assigns[:versioned_jnlp_url].should equal(mock_versioned_jnlp_url)
    end
    
    describe "with mime type of xml" do

      it "renders the requested versioned_jnlp_url as xml" do
        MavenJnlp::VersionedJnlpUrl.should_receive(:find).with("37").and_return(mock_versioned_jnlp_url)
        mock_versioned_jnlp_url.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37", :format => 'xml'
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "GET new" do
  
    it "exposes a new versioned_jnlp_url as @versioned_jnlp_url" do
      MavenJnlp::VersionedJnlpUrl.should_receive(:new).and_return(mock_versioned_jnlp_url)
      get :new
      assigns[:versioned_jnlp_url].should equal(mock_versioned_jnlp_url)
    end

  end

  describe "GET edit" do
  
    it "exposes the requested versioned_jnlp_url as @versioned_jnlp_url" do
      MavenJnlp::VersionedJnlpUrl.should_receive(:find).with("37").and_return(mock_versioned_jnlp_url)
      get :edit, :id => "37"
      assigns[:versioned_jnlp_url].should equal(mock_versioned_jnlp_url)
    end

  end

  describe "POST create" do

    describe "with valid params" do
      
      it "exposes a newly created versioned_jnlp_url as @versioned_jnlp_url" do
        MavenJnlp::VersionedJnlpUrl.should_receive(:new).with({'these' => 'params'}).and_return(mock_versioned_jnlp_url(:save => true))
        post :create, :versioned_jnlp_url => {:these => 'params'}
        assigns(:versioned_jnlp_url).should equal(mock_versioned_jnlp_url)
      end

      it "redirects to the created versioned_jnlp_url" do
        MavenJnlp::VersionedJnlpUrl.stub!(:new).and_return(mock_versioned_jnlp_url(:save => true))
        post :create, :versioned_jnlp_url => {}
        response.should redirect_to(maven_jnlp_versioned_jnlp_url_url(mock_versioned_jnlp_url))
      end
      
    end
    
    describe "with invalid params" do

      it "exposes a newly created but unsaved versioned_jnlp_url as @versioned_jnlp_url" do
        MavenJnlp::VersionedJnlpUrl.stub!(:new).with({'these' => 'params'}).and_return(mock_versioned_jnlp_url(:save => false))
        post :create, :versioned_jnlp_url => {:these => 'params'}
        assigns(:versioned_jnlp_url).should equal(mock_versioned_jnlp_url)
      end

      it "re-renders the 'new' template" do
        MavenJnlp::VersionedJnlpUrl.stub!(:new).and_return(mock_versioned_jnlp_url(:save => false))
        post :create, :versioned_jnlp_url => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "PUT udpate" do

    describe "with valid params" do

      it "updates the requested versioned_jnlp_url" do
        MavenJnlp::VersionedJnlpUrl.should_receive(:find).with("37").and_return(mock_versioned_jnlp_url)
        mock_versioned_jnlp_url.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :versioned_jnlp_url => {:these => 'params'}
      end

      it "exposes the requested versioned_jnlp_url as @versioned_jnlp_url" do
        MavenJnlp::VersionedJnlpUrl.stub!(:find).and_return(mock_versioned_jnlp_url(:update_attributes => true))
        put :update, :id => "1"
        assigns(:versioned_jnlp_url).should equal(mock_versioned_jnlp_url)
      end

      it "redirects to the versioned_jnlp_url" do
        MavenJnlp::VersionedJnlpUrl.stub!(:find).and_return(mock_versioned_jnlp_url(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(maven_jnlp_versioned_jnlp_url_url(mock_versioned_jnlp_url))
      end

    end
    
    describe "with invalid params" do

      it "updates the requested versioned_jnlp_url" do
        MavenJnlp::VersionedJnlpUrl.should_receive(:find).with("37").and_return(mock_versioned_jnlp_url)
        mock_versioned_jnlp_url.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :versioned_jnlp_url => {:these => 'params'}
      end

      it "exposes the versioned_jnlp_url as @versioned_jnlp_url" do
        MavenJnlp::VersionedJnlpUrl.stub!(:find).and_return(mock_versioned_jnlp_url(:update_attributes => false))
        put :update, :id => "1"
        assigns(:versioned_jnlp_url).should equal(mock_versioned_jnlp_url)
      end

      it "re-renders the 'edit' template" do
        MavenJnlp::VersionedJnlpUrl.stub!(:find).and_return(mock_versioned_jnlp_url(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "DELETE destroy" do

    it "destroys the requested versioned_jnlp_url" do
      MavenJnlp::VersionedJnlpUrl.should_receive(:find).with("37").and_return(mock_versioned_jnlp_url)
      mock_versioned_jnlp_url.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "redirects to the maven_jnlp_versioned_jnlp_urls list" do
      MavenJnlp::VersionedJnlpUrl.stub!(:find).and_return(mock_versioned_jnlp_url(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(maven_jnlp_versioned_jnlp_urls_url)
    end

  end

end
