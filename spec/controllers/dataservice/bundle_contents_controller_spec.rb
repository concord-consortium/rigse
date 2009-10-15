require 'spec_helper'

describe Dataservice::BundleContentsController do

  def mock_bundle_content(stubs={})
    @mock_bundle_content ||= mock_model(Dataservice::BundleContent, stubs)
  end

  describe "GET index" do
    it "assigns all dataservice_bundle_contents as @dataservice_bundle_contents" do
      Dataservice::BundleContent.stub!(:find).with(:all).and_return([mock_bundle_content])
      get :index
      assigns[:dataservice_bundle_contents].should == [mock_bundle_content]
    end
  end

  describe "GET show" do
    it "assigns the requested bundle_content as @bundle_content" do
      Dataservice::BundleContent.stub!(:find).with("37").and_return(mock_bundle_content)
      get :show, :id => "37"
      assigns[:bundle_content].should equal(mock_bundle_content)
    end
  end

  describe "GET new" do
    it "assigns a new bundle_content as @bundle_content" do
      Dataservice::BundleContent.stub!(:new).and_return(mock_bundle_content)
      get :new
      assigns[:bundle_content].should equal(mock_bundle_content)
    end
  end

  describe "GET edit" do
    it "assigns the requested bundle_content as @bundle_content" do
      Dataservice::BundleContent.stub!(:find).with("37").and_return(mock_bundle_content)
      get :edit, :id => "37"
      assigns[:bundle_content].should equal(mock_bundle_content)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created bundle_content as @bundle_content" do
        Dataservice::BundleContent.stub!(:new).with({'these' => 'params'}).and_return(mock_bundle_content(:save => true))
        post :create, :bundle_content => {:these => 'params'}
        assigns[:bundle_content].should equal(mock_bundle_content)
      end

      it "redirects to the created bundle_content" do
        Dataservice::BundleContent.stub!(:new).and_return(mock_bundle_content(:save => true))
        post :create, :bundle_content => {}
        response.should redirect_to(dataservice_bundle_content_url(mock_bundle_content))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved bundle_content as @bundle_content" do
        Dataservice::BundleContent.stub!(:new).with({'these' => 'params'}).and_return(mock_bundle_content(:save => false))
        post :create, :bundle_content => {:these => 'params'}
        assigns[:bundle_content].should equal(mock_bundle_content)
      end

      it "re-renders the 'new' template" do
        Dataservice::BundleContent.stub!(:new).and_return(mock_bundle_content(:save => false))
        post :create, :bundle_content => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested bundle_content" do
        Dataservice::BundleContent.should_receive(:find).with("37").and_return(mock_bundle_content)
        mock_bundle_content.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :bundle_content => {:these => 'params'}
      end

      it "assigns the requested bundle_content as @bundle_content" do
        Dataservice::BundleContent.stub!(:find).and_return(mock_bundle_content(:update_attributes => true))
        put :update, :id => "1"
        assigns[:bundle_content].should equal(mock_bundle_content)
      end

      it "redirects to the bundle_content" do
        Dataservice::BundleContent.stub!(:find).and_return(mock_bundle_content(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(dataservice_bundle_content_url(mock_bundle_content))
      end
    end

    describe "with invalid params" do
      it "updates the requested bundle_content" do
        Dataservice::BundleContent.should_receive(:find).with("37").and_return(mock_bundle_content)
        mock_bundle_content.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :bundle_content => {:these => 'params'}
      end

      it "assigns the bundle_content as @bundle_content" do
        Dataservice::BundleContent.stub!(:find).and_return(mock_bundle_content(:update_attributes => false))
        put :update, :id => "1"
        assigns[:bundle_content].should equal(mock_bundle_content)
      end

      it "re-renders the 'edit' template" do
        Dataservice::BundleContent.stub!(:find).and_return(mock_bundle_content(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested bundle_content" do
      Dataservice::BundleContent.should_receive(:find).with("37").and_return(mock_bundle_content)
      mock_bundle_content.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the dataservice_bundle_contents list" do
      Dataservice::BundleContent.stub!(:find).and_return(mock_bundle_content(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(dataservice_bundle_contents_url)
    end
  end

end
