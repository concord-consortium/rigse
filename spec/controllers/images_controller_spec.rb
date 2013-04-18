require File.expand_path('../../spec_helper', __FILE__)
describe ImagesController do

  def mock_image(stubs={})
    @mock_image ||= mock_model(Image, stubs)
  end

  def stub_users_scope(results)
    mock_ar_set = mock(:find => results)
    Image.should_receive(:visible_to_user_with_drafts).
      with(@logged_in_user).
        and_return(mock_ar_set)
  end

  before(:each) do
    @logged_in_user = login_author
  end


  describe "responding to GET index" do

    it "should expose an array of all the @images" do
      Image.should_receive(:search_list).and_return([mock_image])
      get :index, :format => :html
      assigns[:images].should == [mock_image]
    end

  end

  describe "responding to GET show" do
    it "should expose the requested image as @image" do
      stub_users_scope(mock_image)
      get :show, :id => "37"
      assigns[:image].should equal(mock_image)
    end

  end

  describe "responding to GET new" do

    it "should expose a new image as @image" do
      Image.should_receive(:new).and_return(mock_image)
      get :new
      assigns[:image].should equal(mock_image)
    end

  end

  describe "responding to GET edit" do

    it "should expose the requested image as @image" do
      img = mock_image
      img.should_receive(:changeable?).with(@logged_in_user).and_return(true)
      Image.should_receive(:find).with("37").and_return(img)
      get :edit, :id => "37"
      assigns[:image].should equal(img)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      it "should expose a newly created image as @image" do
        img = mock_image
        img.stub(:save => true)

        Image.should_receive(:new).with({'these' => 'params', 'user_id' => @logged_in_user.id.to_s}).and_return(img)
        post :create, :image => {:these => 'params'}
        assigns(:image).should equal(img)
      end

      it "should redirect to the created image" do
        Image.stub!(:new).and_return(mock_image(:save => true))
        post :create, :image => {}
        response.should redirect_to(image_url(mock_image))
      end

    end

    describe "with invalid params" do
      it "should expose a newly created but unsaved image as @image" do
        Image.stub!(:new).with({'these' => 'params','user_id' => @logged_in_user.id.to_s}).and_return(mock_image(:save => false))
        post :create, :image => {:these => 'params'}
        assigns(:image).should equal(mock_image)
      end

      it "should re-render the 'new' template" do
        Image.stub!(:new).and_return(mock_image(:save => false))
        post :create, :image => {}
        response.should render_template('new')
      end

    end

  end

  describe "responding to PUT update" do

    describe "with valid params" do
      before(:each) do
        @img = mock_image(:save => true, :update_attributes => true, :reload => true)
        @img.should_receive(:changeable?).with(@logged_in_user).and_return(true)
      end
      it "should update the requested image" do
        Image.should_receive(:find).with("37").and_return(@img)
        mock_image.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :image => {:these => 'params'}
      end

      it "should expose the requested image as @image" do
        Image.stub!(:find).and_return(@img)
        put :update, :id => "1", :image => {}
        assigns(:image).should equal(@img)
      end

      it "should redirect to the image" do
        Image.stub!(:find).and_return(@img)
        put :update, :id => "1", :format => :html, :image => {}
        response.should redirect_to(@img)
      end

    end

    describe "with invalid params" do
      before(:each) do
        @img = mock_image(:save => false, :update_attributes => false, :reload => false)
        @img.should_receive(:changeable?).with(@logged_in_user).and_return(true)
      end
      it "should update the requested image" do
        Image.should_receive(:find).with("37").and_return(@img)
        @img.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :image => {:these => 'params'}
      end

      it "should expose the image as @image" do
        Image.stub!(:find).and_return(@img)
        put :update, :id => "1"
        assigns(:image).should equal(@img)
      end

      it "should re-render the 'edit' template" do
        Image.stub!(:find).and_return(@img)
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do
    before(:each) do
      @img = mock_image(:destroy => true)
      @img.should_receive(:changeable?).with(@logged_in_user).and_return(true)
    end
    it "should destroy the requested image" do
      Image.should_receive(:find).with("37").and_return(@img)
      mock_image.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "should redirect to the images list" do
      Image.stub!(:find).and_return(@img)
      delete :destroy, :id => "1"
      response.should redirect_to(images_url)
    end

  end

end
