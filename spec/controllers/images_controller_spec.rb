require File.expand_path('../../spec_helper', __FILE__)
describe ImagesController do

  def mock_image(stubs={})
    @mock_image ||= mock_model(Image, stubs)
  end

  def stub_users_scope(results)
    mock_ar_set = double(:find => results)
    expect(Image).to receive(:visible_to_user_with_drafts).
      with(@logged_in_user).
        and_return(mock_ar_set)
  end

  before(:each) do
    @logged_in_user = login_author
  end


  describe "responding to GET index" do

    it "should expose an array of all the @images" do
      expect(Image).to receive(:search_list).and_return([mock_image])
      get :index, :format => :html
      expect(assigns[:images]).to eq([mock_image])
    end

  end

  describe "responding to GET show" do
    it "should expose the requested image as @image" do
      stub_users_scope(mock_image)
      get :show, :id => "37"
      expect(assigns[:image]).to equal(mock_image)
    end

  end

  describe "responding to GET new" do

    it "should expose a new image as @image" do
      expect(Image).to receive(:new).and_return(mock_image)
      get :new
      expect(assigns[:image]).to equal(mock_image)
    end

  end

  describe "responding to GET edit" do

    it "should expose the requested image as @image" do
      img = mock_image
      expect(img).to receive(:changeable?).with(@logged_in_user).and_return(true)
      expect(Image).to receive(:find).with("37").and_return(img)
      get :edit, :id => "37"
      expect(assigns[:image]).to equal(img)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      it "should expose a newly created image as @image" do
        img = mock_image
        img.stub(:save => true)

        expect(Image).to receive(:new).with({'these' => 'params', 'user_id' => @logged_in_user.id.to_s}).and_return(img)
        post :create, :image => {:these => 'params'}
        expect(assigns(:image)).to equal(img)
      end

      it "should redirect to the created image" do
        allow(Image).to receive(:new).and_return(mock_image(:save => true))
        post :create, :image => {}
        expect(response).to redirect_to(image_url(mock_image))
      end

    end

    describe "with invalid params" do
      it "should expose a newly created but unsaved image as @image" do
        allow(Image).to receive(:new).with({'these' => 'params','user_id' => @logged_in_user.id.to_s}).and_return(mock_image(:save => false))
        post :create, :image => {:these => 'params'}
        expect(assigns(:image)).to equal(mock_image)
      end

      it "should re-render the 'new' template" do
        allow(Image).to receive(:new).and_return(mock_image(:save => false))
        post :create, :image => {}
        expect(response).to render_template('new')
      end

    end

  end

  describe "responding to PUT update" do

    describe "with valid params" do
      before(:each) do
        @img = mock_image(:save => true, :update_attributes => true, :reload => true)
        expect(@img).to receive(:changeable?).with(@logged_in_user).and_return(true)
      end
      it "should update the requested image" do
        expect(Image).to receive(:find).with("37").and_return(@img)
        expect(mock_image).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :image => {:these => 'params'}
      end

      it "should expose the requested image as @image" do
        allow(Image).to receive(:find).and_return(@img)
        put :update, :id => "1", :image => {}
        expect(assigns(:image)).to equal(@img)
      end

      it "should redirect to the image" do
        allow(Image).to receive(:find).and_return(@img)
        put :update, :id => "1", :format => :html, :image => {}
        expect(response).to redirect_to(@img)
      end

    end

    describe "with invalid params" do
      before(:each) do
        @img = mock_image(:save => false, :update_attributes => false, :reload => false)
        expect(@img).to receive(:changeable?).with(@logged_in_user).and_return(true)
      end
      it "should update the requested image" do
        expect(Image).to receive(:find).with("37").and_return(@img)
        expect(@img).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :image => {:these => 'params'}
      end

      it "should expose the image as @image" do
        allow(Image).to receive(:find).and_return(@img)
        put :update, :id => "1"
        expect(assigns(:image)).to equal(@img)
      end

      it "should re-render the 'edit' template" do
        allow(Image).to receive(:find).and_return(@img)
        put :update, :id => "1"
        expect(response).to render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do
    before(:each) do
      @img = mock_image(:destroy => true)
      expect(@img).to receive(:changeable?).with(@logged_in_user).and_return(true)
    end
    it "should destroy the requested image" do
      expect(Image).to receive(:find).with("37").and_return(@img)
      expect(mock_image).to receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "should redirect to the images list" do
      allow(Image).to receive(:find).and_return(@img)
      delete :destroy, :id => "1"
      expect(response).to redirect_to(images_url)
    end

  end

end
