require 'spec_helper'

describe MavenJnlp::MavenJnlpServersController do

  def mock_maven_jnlp_server(stubs={})
    @mock_maven_jnlp_server.stub!(stubs) unless stubs.empty?
    @mock_maven_jnlp_server
  end

  before(:each) do
    generate_default_project_and_jnlps_with_factories
    logout_user
  end

  describe "GET index" do

    it "exposes all maven_jnlp_maven_jnlp_servers as @maven_jnlp_maven_jnlp_servers" do
      MavenJnlp::MavenJnlpServer.should_receive(:find).with(:all).and_return([mock_maven_jnlp_server])
      get :index
      assigns[:maven_jnlp_maven_jnlp_servers].should == [mock_maven_jnlp_server]
    end

    describe "with mime type of xml" do

      it "renders all maven_jnlp_maven_jnlp_servers as xml" do
        MavenJnlp::MavenJnlpServer.should_receive(:find).with(:all).and_return(maven_jnlp_servers = mock("Array of MavenJnlp::MavenJnlpServers"))
        maven_jnlp_servers.should_receive(:to_xml).and_return("generated XML")
        get :index, :format => 'xml'
        response.body.should == "generated XML"
      end

    end

  end

  describe "GET show" do

    it "exposes the requested maven_jnlp_server as @maven_jnlp_server" do
      MavenJnlp::MavenJnlpServer.should_receive(:find).with("37").and_return(mock_maven_jnlp_server)
      get :show, :id => "37"
      assigns[:maven_jnlp_server].should equal(mock_maven_jnlp_server)
    end

    describe "with mime type of xml" do

      it "renders the requested maven_jnlp_server as xml" do
        MavenJnlp::MavenJnlpServer.should_receive(:find).with("37").and_return(mock_maven_jnlp_server)
        mock_maven_jnlp_server.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37", :format => 'xml'
        response.body.should == "generated XML"
      end

    end

  end

  describe "GET new" do

    it "exposes a new maven_jnlp_server as @maven_jnlp_server" do
      MavenJnlp::MavenJnlpServer.should_receive(:new).and_return(mock_maven_jnlp_server)
      get :new
      assigns[:maven_jnlp_server].should equal(mock_maven_jnlp_server)
    end

  end

  describe "GET edit" do

    it "exposes the requested maven_jnlp_server as @maven_jnlp_server" do
      MavenJnlp::MavenJnlpServer.should_receive(:find).with("37").and_return(mock_maven_jnlp_server)
      get :edit, :id => "37"
      assigns[:maven_jnlp_server].should equal(mock_maven_jnlp_server)
    end

  end

  describe "POST create" do

    describe "with valid params" do

      it "exposes a newly created maven_jnlp_server as @maven_jnlp_server" do
        MavenJnlp::MavenJnlpServer.should_receive(:new).with({'these' => 'params'}).and_return(mock_maven_jnlp_server(:save => true))
        post :create, :maven_jnlp_server => {:these => 'params'}
        assigns(:maven_jnlp_server).should equal(mock_maven_jnlp_server)
      end

      it "redirects to the created maven_jnlp_server" do
        MavenJnlp::MavenJnlpServer.stub!(:new).and_return(mock_maven_jnlp_server(:save => true))
        post :create, :maven_jnlp_server => {}
        response.should redirect_to(maven_jnlp_maven_jnlp_server_url(mock_maven_jnlp_server))
      end

    end

    describe "with invalid params" do

      it "exposes a newly created but unsaved maven_jnlp_server as @maven_jnlp_server" do
        MavenJnlp::MavenJnlpServer.stub!(:new).with({'these' => 'params'}).and_return(mock_maven_jnlp_server(:save => false))
        post :create, :maven_jnlp_server => {:these => 'params'}
        assigns(:maven_jnlp_server).should equal(mock_maven_jnlp_server)
      end

      it "re-renders the 'new' template" do
        MavenJnlp::MavenJnlpServer.stub!(:new).and_return(mock_maven_jnlp_server(:save => false))
        post :create, :maven_jnlp_server => {}
        response.should render_template('new')
      end

    end

  end

  describe "PUT udpate" do

    describe "with valid params" do

      it "updates the requested maven_jnlp_server" do
        MavenJnlp::MavenJnlpServer.should_receive(:find).with("37").and_return(mock_maven_jnlp_server)
        mock_maven_jnlp_server.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :maven_jnlp_server => {:these => 'params'}
      end

      it "exposes the requested maven_jnlp_server as @maven_jnlp_server" do
        MavenJnlp::MavenJnlpServer.stub!(:find).and_return(mock_maven_jnlp_server(:update_attributes => true))
        put :update, :id => "1"
        assigns(:maven_jnlp_server).should equal(mock_maven_jnlp_server)
      end

      it "redirects to the maven_jnlp_server" do
        MavenJnlp::MavenJnlpServer.stub!(:find).and_return(mock_maven_jnlp_server(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(maven_jnlp_maven_jnlp_server_url(mock_maven_jnlp_server))
      end

    end

    describe "with invalid params" do

      it "updates the requested maven_jnlp_server" do
        MavenJnlp::MavenJnlpServer.should_receive(:find).with("37").and_return(mock_maven_jnlp_server)
        mock_maven_jnlp_server.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :maven_jnlp_server => {:these => 'params'}
      end

      it "exposes the maven_jnlp_server as @maven_jnlp_server" do
        MavenJnlp::MavenJnlpServer.stub!(:find).and_return(mock_maven_jnlp_server(:update_attributes => false))
        put :update, :id => "1"
        assigns(:maven_jnlp_server).should equal(mock_maven_jnlp_server)
      end

      it "re-renders the 'edit' template" do
        MavenJnlp::MavenJnlpServer.stub!(:find).and_return(mock_maven_jnlp_server(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "DELETE destroy" do

    it "destroys the requested maven_jnlp_server" do
      MavenJnlp::MavenJnlpServer.should_receive(:find).with("37").and_return(mock_maven_jnlp_server)
      mock_maven_jnlp_server.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the maven_jnlp_maven_jnlp_servers list" do
      MavenJnlp::MavenJnlpServer.stub!(:find).and_return(mock_maven_jnlp_server(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(maven_jnlp_maven_jnlp_servers_url)
    end
  end
end
