require 'spec_helper'

describe OtrunkExample::OtmlCategoriesController do

  def mock_otml_category(stubs={})
    @mock_otml_category.stub!(stubs) unless stubs.empty?
    @mock_otml_category
  end
  
  before(:each) do
    generate_default_project_and_jnlps_with_mocks
    generate_otrunk_example_with_mocks
    logout_user
  end
  
  describe "GET index" do

    it "exposes all otrunk_example_otml_categories as @otrunk_example_otml_categories" do
      OtrunkExample::OtmlCategory.should_receive(:find).with(:all).and_return([mock_otml_category])
      get :index
      assigns[:otrunk_example_otml_categories].should == [mock_otml_category]
    end

    describe "with mime type of xml" do
  
      it "renders all otrunk_example_otml_categories as xml" do
        OtrunkExample::OtmlCategory.should_receive(:find).with(:all).and_return(otml_categories = mock("Array of OtrunkExample::OtmlCategories"))
        otml_categories.should_receive(:to_xml).and_return("generated XML")
        get :index, :format => 'xml'
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "GET show" do

    it "exposes the requested otml_category as @otml_category" do
      OtrunkExample::OtmlCategory.should_receive(:find).with("37").and_return(mock_otml_category)
      get :show, :id => "37"
      assigns[:otml_category].should equal(mock_otml_category)
    end
    
    describe "with mime type of xml" do

      it "renders the requested otml_category as xml" do
        OtrunkExample::OtmlCategory.should_receive(:find).with("37").and_return(mock_otml_category)
        mock_otml_category.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37", :format => 'xml'
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "GET new" do
  
    it "exposes a new otml_category as @otml_category" do
      OtrunkExample::OtmlCategory.should_receive(:new).and_return(mock_otml_category)
      get :new
      assigns[:otml_category].should equal(mock_otml_category)
    end

  end

  describe "GET edit" do
  
    it "exposes the requested otml_category as @otml_category" do
      OtrunkExample::OtmlCategory.should_receive(:find).with("37").and_return(mock_otml_category)
      get :edit, :id => "37"
      assigns[:otml_category].should equal(mock_otml_category)
    end

  end

  describe "POST create" do

    describe "with valid params" do
      
      it "exposes a newly created otml_category as @otml_category" do
        OtrunkExample::OtmlCategory.should_receive(:new).with({'these' => 'params'}).and_return(mock_otml_category(:save => true))
        post :create, :otml_category => {:these => 'params'}
        assigns(:otml_category).should equal(mock_otml_category)
      end

      it "redirects to the created otml_category" do
        OtrunkExample::OtmlCategory.stub!(:new).and_return(mock_otml_category(:save => true))
        post :create, :otml_category => {}
        response.should redirect_to(otrunk_example_otml_category_url(mock_otml_category))
      end
      
    end
    
    describe "with invalid params" do

      it "exposes a newly created but unsaved otml_category as @otml_category" do
        OtrunkExample::OtmlCategory.stub!(:new).with({'these' => 'params'}).and_return(mock_otml_category(:save => false))
        post :create, :otml_category => {:these => 'params'}
        assigns(:otml_category).should equal(mock_otml_category)
      end

      it "re-renders the 'new' template" do
        OtrunkExample::OtmlCategory.stub!(:new).and_return(mock_otml_category(:save => false))
        post :create, :otml_category => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "PUT udpate" do

    describe "with valid params" do

      it "updates the requested otml_category" do
        OtrunkExample::OtmlCategory.should_receive(:find).with("37").and_return(mock_otml_category)
        mock_otml_category.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :otml_category => {:these => 'params'}
      end

      it "exposes the requested otml_category as @otml_category" do
        OtrunkExample::OtmlCategory.stub!(:find).and_return(mock_otml_category(:update_attributes => true))
        put :update, :id => "1"
        assigns(:otml_category).should equal(mock_otml_category)
      end

      it "redirects to the otml_category" do
        OtrunkExample::OtmlCategory.stub!(:find).and_return(mock_otml_category(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(otrunk_example_otml_category_url(mock_otml_category))
      end

    end
    
    describe "with invalid params" do

      it "updates the requested otml_category" do
        OtrunkExample::OtmlCategory.should_receive(:find).with("37").and_return(mock_otml_category)
        mock_otml_category.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :otml_category => {:these => 'params'}
      end

      it "exposes the otml_category as @otml_category" do
        OtrunkExample::OtmlCategory.stub!(:find).and_return(mock_otml_category(:update_attributes => false))
        put :update, :id => "1"
        assigns(:otml_category).should equal(mock_otml_category)
      end

      it "re-renders the 'edit' template" do
        OtrunkExample::OtmlCategory.stub!(:find).and_return(mock_otml_category(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "DELETE destroy" do

    it "destroys the requested otml_category" do
      OtrunkExample::OtmlCategory.should_receive(:find).with("37").and_return(mock_otml_category)
      mock_otml_category.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "redirects to the otrunk_example_otml_categories list" do
      OtrunkExample::OtmlCategory.stub!(:find).and_return(mock_otml_category(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(otrunk_example_otml_categories_url)
    end

  end

end
