require 'spec_helper'

describe Admin::TagsController do

  def mock_tags(stubs={})
    @mock_tags ||= mock_model(Admin::Tag, stubs)
  end

  describe "GET index" do
    it "assigns all admin_tags as @admin_tags" do
      Admin::Tag.stub(:find).with(:all, {:offset=>0, :limit=>30, :include=>{}, :conditions=>["(admin_tags.scope like ? or admin_tags.tag like ?)", "%%", "%%"]}).and_return([mock_tags])
      get :index
      assigns[:admin_tags].should == [mock_tags]
    end
  end

  describe "GET show" do
    it "assigns the requested tags as @tags" do
      Admin::Tag.stub(:find).with("37").and_return(mock_tags)
      get :show, :id => "37"
      assigns[:admin_tag].should equal(mock_tags)
    end
  end

  describe "GET new" do
    it "assigns a new tags as @tags" do
      Admin::Tag.stub(:new).and_return(mock_tags)
      get :new
      assigns[:admin_tag].should equal(mock_tags)
    end
  end

  describe "GET edit" do
    it "assigns the requested tags as @tags" do
      Admin::Tag.stub(:find).with("37").and_return(mock_tags)
      get :edit, :id => "37"
      assigns[:admin_tag].should equal(mock_tags)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created tags as @tags" do
        Admin::Tag.stub(:new).with({'these' => 'params'}).and_return(mock_tags(:save => true))
        post :create, :admin_tag => {:these => 'params'}
        assigns[:admin_tag].should equal(mock_tags)
      end

      it "redirects to the created tags" do
        Admin::Tag.stub(:new).and_return(mock_tags(:save => true))
        post :create, :admin_tag => {}
        response.should redirect_to(admin_tag_url(mock_tags))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved tags as @tags" do
        Admin::Tag.stub(:new).with({'these' => 'params'}).and_return(mock_tags(:save => false))
        post :create, :admin_tag => {:these => 'params'}
        assigns[:admin_tag].should equal(mock_tags)
      end

      it "re-renders the 'new' template" do
        Admin::Tag.stub(:new).and_return(mock_tags(:save => false))
        post :create, :admin_tag => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested tags" do
        Admin::Tag.should_receive(:find).with("37").and_return(mock_tags)
        mock_tags.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :admin_tag => {:these => 'params'}
      end

      it "assigns the requested tags as @tags" do
        Admin::Tag.stub(:find).and_return(mock_tags(:update_attributes => true))
        put :update, :id => "1"
        assigns[:admin_tag].should equal(mock_tags)
      end

      it "redirects to the tags" do
        Admin::Tag.stub(:find).and_return(mock_tags(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(admin_tag_url(mock_tags))
      end
    end

    describe "with invalid params" do
      it "updates the requested tags" do
        Admin::Tag.should_receive(:find).with("37").and_return(mock_tags)
        mock_tags.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :admin_tag => {:these => 'params'}
      end

      it "assigns the tags as @tags" do
        Admin::Tag.stub(:find).and_return(mock_tags(:update_attributes => false))
        put :update, :id => "1"
        assigns[:admin_tag].should equal(mock_tags)
      end

      it "re-renders the 'edit' template" do
        Admin::Tag.stub(:find).and_return(mock_tags(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested tags" do
      Admin::Tag.should_receive(:find).with("37").and_return(mock_tags)
      mock_tags.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the admin_tags list" do
      Admin::Tag.stub(:find).and_return(mock_tags(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(admin_tags_url)
    end
  end

end
