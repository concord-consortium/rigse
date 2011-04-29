require 'spec_helper'

describe MavenJnlp::JarsController do

  def mock_jar(stubs={})
    @mock_jar ||= mock_model(MavenJnlp::Jar, stubs)
  end

  before(:each) do
    generate_default_project_and_jnlps_with_mocks
    logout_user
  end

  describe "GET index" do

    it "exposes all maven_jnlp_jars as @maven_jnlp_jars" do
      MavenJnlp::Jar.should_receive(:find).with(:all).and_return([mock_jar])
      get :index
      assigns[:maven_jnlp_jars].should == [mock_jar]
    end

    describe "with mime type of xml" do
  
      it "renders all maven_jnlp_jars as xml" do
        MavenJnlp::Jar.should_receive(:find).with(:all).and_return(jars = mock("Array of MavenJnlp::Jars"))
        jars.should_receive(:to_xml).and_return("generated XML")
        get :index, :format => 'xml'
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "GET show" do

    it "exposes the requested jar as @jar" do
      MavenJnlp::Jar.should_receive(:find).with("37").and_return(mock_jar)
      get :show, :id => "37"
      assigns[:jar].should equal(mock_jar)
    end
    
    describe "with mime type of xml" do

      it "renders the requested jar as xml" do
        MavenJnlp::Jar.should_receive(:find).with("37").and_return(mock_jar)
        mock_jar.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37", :format => 'xml'
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "GET new" do
  
    it "exposes a new jar as @jar" do
      MavenJnlp::Jar.should_receive(:new).and_return(mock_jar)
      get :new
      assigns[:jar].should equal(mock_jar)
    end

  end

  describe "GET edit" do
  
    it "exposes the requested jar as @jar" do
      MavenJnlp::Jar.should_receive(:find).with("37").and_return(mock_jar)
      get :edit, :id => "37"
      assigns[:jar].should equal(mock_jar)
    end

  end

  describe "POST create" do

    describe "with valid params" do
      
      it "exposes a newly created jar as @jar" do
        MavenJnlp::Jar.should_receive(:new).with({'these' => 'params'}).and_return(mock_jar(:save => true))
        post :create, :jar => {:these => 'params'}
        assigns(:jar).should equal(mock_jar)
      end

      it "redirects to the created jar" do
        MavenJnlp::Jar.stub!(:new).and_return(mock_jar(:save => true))
        post :create, :jar => {}
        response.should redirect_to(maven_jnlp_jar_url(mock_jar))
      end
      
    end
    
    describe "with invalid params" do

      it "exposes a newly created but unsaved jar as @jar" do
        MavenJnlp::Jar.stub!(:new).with({'these' => 'params'}).and_return(mock_jar(:save => false))
        post :create, :jar => {:these => 'params'}
        assigns(:jar).should equal(mock_jar)
      end

      it "re-renders the 'new' template" do
        MavenJnlp::Jar.stub!(:new).and_return(mock_jar(:save => false))
        post :create, :jar => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "PUT udpate" do

    describe "with valid params" do

      it "updates the requested jar" do
        MavenJnlp::Jar.should_receive(:find).with("37").and_return(mock_jar)
        mock_jar.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :jar => {:these => 'params'}
      end

      it "exposes the requested jar as @jar" do
        MavenJnlp::Jar.stub!(:find).and_return(mock_jar(:update_attributes => true))
        put :update, :id => "1"
        assigns(:jar).should equal(mock_jar)
      end

      it "redirects to the jar" do
        MavenJnlp::Jar.stub!(:find).and_return(mock_jar(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(maven_jnlp_jar_url(mock_jar))
      end

    end
    
    describe "with invalid params" do

      it "updates the requested jar" do
        MavenJnlp::Jar.should_receive(:find).with("37").and_return(mock_jar)
        mock_jar.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :jar => {:these => 'params'}
      end

      it "exposes the jar as @jar" do
        MavenJnlp::Jar.stub!(:find).and_return(mock_jar(:update_attributes => false))
        put :update, :id => "1"
        assigns(:jar).should equal(mock_jar)
      end

      it "re-renders the 'edit' template" do
        MavenJnlp::Jar.stub!(:find).and_return(mock_jar(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "DELETE destroy" do

    it "destroys the requested jar" do
      MavenJnlp::Jar.should_receive(:find).with("37").and_return(mock_jar)
      mock_jar.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "redirects to the maven_jnlp_jars list" do
      MavenJnlp::Jar.stub!(:find).and_return(mock_jar(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(maven_jnlp_jars_url)
    end

  end

end
