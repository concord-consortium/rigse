require 'spec_helper'

describe Portal::GradeLevelsController do

  def mock_grade_level(stubs={})
    @mock_grade_level ||= mock_model(Portal::GradeLevel, stubs)
  end

  describe "GET index" do
    it "assigns all portal_grade_levels as @portal_grade_levels" do
      pending "Broken example"
      Portal::GradeLevel.stub!(:find).with(:all).and_return([mock_grade_level])
      get :index
      assigns[:portal_grade_levels].should == [mock_grade_level]
    end
  end

  describe "GET show" do
    it "assigns the requested grade_level as @grade_level" do
      pending "Broken example"
      Portal::GradeLevel.stub!(:find).with("37").and_return(mock_grade_level)
      get :show, :id => "37"
      assigns[:grade_level].should equal(mock_grade_level)
    end
  end

  describe "GET new" do
    it "assigns a new grade_level as @grade_level" do
      pending "Broken example"
      Portal::GradeLevel.stub!(:new).and_return(mock_grade_level)
      get :new
      assigns[:grade_level].should equal(mock_grade_level)
    end
  end

  describe "GET edit" do
    it "assigns the requested grade_level as @grade_level" do
      pending "Broken example"
      Portal::GradeLevel.stub!(:find).with("37").and_return(mock_grade_level)
      get :edit, :id => "37"
      assigns[:grade_level].should equal(mock_grade_level)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created grade_level as @grade_level" do
        pending "Broken example"
        Portal::GradeLevel.stub!(:new).with({'these' => 'params'}).and_return(mock_grade_level(:save => true))
        post :create, :grade_level => {:these => 'params'}
        assigns[:grade_level].should equal(mock_grade_level)
      end

      it "redirects to the created grade_level" do
        pending "Broken example"
        Portal::GradeLevel.stub!(:new).and_return(mock_grade_level(:save => true))
        post :create, :grade_level => {}
        response.should redirect_to(portal_grade_level_url(mock_grade_level))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved grade_level as @grade_level" do
        pending "Broken example"
        Portal::GradeLevel.stub!(:new).with({'these' => 'params'}).and_return(mock_grade_level(:save => false))
        post :create, :grade_level => {:these => 'params'}
        assigns[:grade_level].should equal(mock_grade_level)
      end

      it "re-renders the 'new' template" do
        pending "Broken example"
        Portal::GradeLevel.stub!(:new).and_return(mock_grade_level(:save => false))
        post :create, :grade_level => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested grade_level" do
        pending "Broken example"
        Portal::GradeLevel.should_receive(:find).with("37").and_return(mock_grade_level)
        mock_grade_level.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :grade_level => {:these => 'params'}
      end

      it "assigns the requested grade_level as @grade_level" do
        pending "Broken example"
        Portal::GradeLevel.stub!(:find).and_return(mock_grade_level(:update_attributes => true))
        put :update, :id => "1"
        assigns[:grade_level].should equal(mock_grade_level)
      end

      it "redirects to the grade_level" do
        pending "Broken example"
        Portal::GradeLevel.stub!(:find).and_return(mock_grade_level(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(portal_grade_level_url(mock_grade_level))
      end
    end

    describe "with invalid params" do
      it "updates the requested grade_level" do
        pending "Broken example"
        Portal::GradeLevel.should_receive(:find).with("37").and_return(mock_grade_level)
        mock_grade_level.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :grade_level => {:these => 'params'}
      end

      it "assigns the grade_level as @grade_level" do
        pending "Broken example"
        Portal::GradeLevel.stub!(:find).and_return(mock_grade_level(:update_attributes => false))
        put :update, :id => "1"
        assigns[:grade_level].should equal(mock_grade_level)
      end

      it "re-renders the 'edit' template" do
        pending "Broken example"
        Portal::GradeLevel.stub!(:find).and_return(mock_grade_level(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested grade_level" do
      pending "Broken example"
      Portal::GradeLevel.should_receive(:find).with("37").and_return(mock_grade_level)
      mock_grade_level.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the portal_grade_levels list" do
      pending "Broken example"
      Portal::GradeLevel.stub!(:find).and_return(mock_grade_level(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(portal_grade_levels_url)
    end
  end

end
