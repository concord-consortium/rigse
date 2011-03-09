require 'spec_helper'

describe MavenJnlp::NativeLibrariesController do

  def mock_native_library(stubs={})
    @mock_native_library ||= mock_model(MavenJnlp::NativeLibrary, stubs)
  end

  before(:each) do
    generate_default_project_and_jnlps_with_factories
    logout_user
  end

  describe "GET index" do

    it "exposes all maven_jnlp_native_libraries as @maven_jnlp_native_libraries" do
      MavenJnlp::NativeLibrary.should_receive(:find).with(:all).and_return([mock_native_library])
      get :index
      assigns[:maven_jnlp_native_libraries].should == [mock_native_library]
    end

    describe "with mime type of xml" do

      it "renders all maven_jnlp_native_libraries as xml" do
        MavenJnlp::NativeLibrary.should_receive(:find).with(:all).and_return(native_libraries = mock("Array of MavenJnlp::NativeLibraries"))
        native_libraries.should_receive(:to_xml).and_return("generated XML")
        get :index, :format => 'xml'
        response.body.should == "generated XML"
      end

    end

  end

  describe "GET show" do

    it "exposes the requested native_library as @native_library" do
      MavenJnlp::NativeLibrary.should_receive(:find).with("37").and_return(mock_native_library)
      get :show, :id => "37"
      assigns[:native_library].should equal(mock_native_library)
    end

    describe "with mime type of xml" do

      it "renders the requested native_library as xml" do
        MavenJnlp::NativeLibrary.should_receive(:find).with("37").and_return(mock_native_library)
        mock_native_library.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37", :format => 'xml'
        response.body.should == "generated XML"
      end

    end

  end

  describe "GET new" do

    it "exposes a new native_library as @native_library" do
      MavenJnlp::NativeLibrary.should_receive(:new).and_return(mock_native_library)
      get :new
      assigns[:native_library].should equal(mock_native_library)
    end

  end

  describe "GET edit" do

    it "exposes the requested native_library as @native_library" do
      MavenJnlp::NativeLibrary.should_receive(:find).with("37").and_return(mock_native_library)
      get :edit, :id => "37"
      assigns[:native_library].should equal(mock_native_library)
    end

  end

  describe "POST create" do

    describe "with valid params" do

      it "exposes a newly created native_library as @native_library" do
        MavenJnlp::NativeLibrary.should_receive(:new).with({'these' => 'params'}).and_return(mock_native_library(:save => true))
        post :create, :native_library => {:these => 'params'}
        assigns(:native_library).should equal(mock_native_library)
      end

      it "redirects to the created native_library" do
        MavenJnlp::NativeLibrary.stub!(:new).and_return(mock_native_library(:save => true))
        post :create, :native_library => {}
        response.should redirect_to(maven_jnlp_native_library_url(mock_native_library))
      end

    end

    describe "with invalid params" do

      it "exposes a newly created but unsaved native_library as @native_library" do
        MavenJnlp::NativeLibrary.stub!(:new).with({'these' => 'params'}).and_return(mock_native_library(:save => false))
        post :create, :native_library => {:these => 'params'}
        assigns(:native_library).should equal(mock_native_library)
      end

      it "re-renders the 'new' template" do
        MavenJnlp::NativeLibrary.stub!(:new).and_return(mock_native_library(:save => false))
        post :create, :native_library => {}
        response.should render_template('new')
      end

    end

  end

  describe "PUT udpate" do

    describe "with valid params" do

      it "updates the requested native_library" do
        MavenJnlp::NativeLibrary.should_receive(:find).with("37").and_return(mock_native_library)
        mock_native_library.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :native_library => {:these => 'params'}
      end

      it "exposes the requested native_library as @native_library" do
        MavenJnlp::NativeLibrary.stub!(:find).and_return(mock_native_library(:update_attributes => true))
        put :update, :id => "1"
        assigns(:native_library).should equal(mock_native_library)
      end

      it "redirects to the native_library" do
        MavenJnlp::NativeLibrary.stub!(:find).and_return(mock_native_library(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(maven_jnlp_native_library_url(mock_native_library))
      end

    end

    describe "with invalid params" do

      it "updates the requested native_library" do
        MavenJnlp::NativeLibrary.should_receive(:find).with("37").and_return(mock_native_library)
        mock_native_library.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :native_library => {:these => 'params'}
      end

      it "exposes the native_library as @native_library" do
        MavenJnlp::NativeLibrary.stub!(:find).and_return(mock_native_library(:update_attributes => false))
        put :update, :id => "1"
        assigns(:native_library).should equal(mock_native_library)
      end

      it "re-renders the 'edit' template" do
        MavenJnlp::NativeLibrary.stub!(:find).and_return(mock_native_library(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "DELETE destroy" do

    it "destroys the requested native_library" do
      MavenJnlp::NativeLibrary.should_receive(:find).with("37").and_return(mock_native_library)
      mock_native_library.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the maven_jnlp_native_libraries list" do
      MavenJnlp::NativeLibrary.stub!(:find).and_return(mock_native_library(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(maven_jnlp_native_libraries_url)
    end
  end
end
