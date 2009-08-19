require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Portal::GradesController do

  def mock_grade(stubs={})
    @mock_grade ||= mock_model(Portal::Grade, stubs)
  end

  describe "GET index" do
    it "assigns all portal_grades as @portal_grades" do
      Portal::Grade.stub!(:find).with(:all).and_return([mock_grade])
      get :index
      assigns[:portal_grades].should == [mock_grade]
    end
  end

  describe "GET show" do
    it "assigns the requested grade as @grade" do
      Portal::Grade.stub!(:find).with("37").and_return(mock_grade)
      get :show, :id => "37"
      assigns[:grade].should equal(mock_grade)
    end
  end

  describe "GET new" do
    it "assigns a new grade as @grade" do
      Portal::Grade.stub!(:new).and_return(mock_grade)
      get :new
      assigns[:grade].should equal(mock_grade)
    end
  end

  describe "GET edit" do
    it "assigns the requested grade as @grade" do
      Portal::Grade.stub!(:find).with("37").and_return(mock_grade)
      get :edit, :id => "37"
      assigns[:grade].should equal(mock_grade)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created grade as @grade" do
        Portal::Grade.stub!(:new).with({'these' => 'params'}).and_return(mock_grade(:save => true))
        post :create, :grade => {:these => 'params'}
        assigns[:grade].should equal(mock_grade)
      end

      it "redirects to the created grade" do
        Portal::Grade.stub!(:new).and_return(mock_grade(:save => true))
        post :create, :grade => {}
        response.should redirect_to(portal_grade_url(mock_grade))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved grade as @grade" do
        Portal::Grade.stub!(:new).with({'these' => 'params'}).and_return(mock_grade(:save => false))
        post :create, :grade => {:these => 'params'}
        assigns[:grade].should equal(mock_grade)
      end

      it "re-renders the 'new' template" do
        Portal::Grade.stub!(:new).and_return(mock_grade(:save => false))
        post :create, :grade => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested grade" do
        Portal::Grade.should_receive(:find).with("37").and_return(mock_grade)
        mock_grade.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :grade => {:these => 'params'}
      end

      it "assigns the requested grade as @grade" do
        Portal::Grade.stub!(:find).and_return(mock_grade(:update_attributes => true))
        put :update, :id => "1"
        assigns[:grade].should equal(mock_grade)
      end

      it "redirects to the grade" do
        Portal::Grade.stub!(:find).and_return(mock_grade(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(portal_grade_url(mock_grade))
      end
    end

    describe "with invalid params" do
      it "updates the requested grade" do
        Portal::Grade.should_receive(:find).with("37").and_return(mock_grade)
        mock_grade.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :grade => {:these => 'params'}
      end

      it "assigns the grade as @grade" do
        Portal::Grade.stub!(:find).and_return(mock_grade(:update_attributes => false))
        put :update, :id => "1"
        assigns[:grade].should equal(mock_grade)
      end

      it "re-renders the 'edit' template" do
        Portal::Grade.stub!(:find).and_return(mock_grade(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested grade" do
      Portal::Grade.should_receive(:find).with("37").and_return(mock_grade)
      mock_grade.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the portal_grades list" do
      Portal::Grade.stub!(:find).and_return(mock_grade(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(portal_grades_url)
    end
  end

end
