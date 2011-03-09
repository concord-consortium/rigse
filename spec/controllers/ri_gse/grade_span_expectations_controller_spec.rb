require 'spec_helper'

describe RiGse::GradeSpanExpectationsController do

  def mock_grade_span_expectation(stubs={})
    @mock_grade_span_expectation ||= mock_model(RiGse::GradeSpanExpectation, stubs)
  end

  before(:each) do
    generate_default_project_and_jnlps_with_factories
    # generate_portal_resources_with_mocks
    login_admin
    #Admin::Project.should_receive(:default_project).and_return(@mock_project)
  end

  describe "responding to GET index" do

    it "should expose a paginated array of @grade_span_expectations" do
      RiGse::GradeSpanExpectation.should_receive(:find).with(:all, hash_including(will_paginate_params)).and_return([mock_grade_span_expectation])
      get :index
      assigns[:grade_span_expectations].should == [mock_grade_span_expectation]
    end

    describe "with mime type of xml" do

      it "should render all grade_span_expectations as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        RiGse::GradeSpanExpectation.should_receive(:find).with(:all).and_return(grade_span_expectations = mock("Array of GradeSpanExpectations"))
        grade_span_expectations.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end

    end

  end

  describe "responding to GET show" do

    it "should expose the requested grade_span_expectation as @grade_span_expectation" do
      RiGse::GradeSpanExpectation.should_receive(:find).with("37").and_return(mock_grade_span_expectation)
      get :show, :id => "37"
      assigns[:grade_span_expectation].should equal(mock_grade_span_expectation)
    end

    describe "with mime type of xml" do

      it "should render the requested grade_span_expectation as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        RiGse::GradeSpanExpectation.should_receive(:find).with("37").and_return(mock_grade_span_expectation)
        mock_grade_span_expectation.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end

  end

  describe "responding to GET new" do

    it "should expose a new grade_span_expectation as @grade_span_expectation" do
      RiGse::GradeSpanExpectation.should_receive(:new).and_return(mock_grade_span_expectation)
      get :new
      assigns[:grade_span_expectation].should equal(mock_grade_span_expectation)
    end

  end

  describe "responding to GET edit" do

    it "should expose the requested grade_span_expectation as @grade_span_expectation" do
      RiGse::GradeSpanExpectation.should_receive(:find).with("37").and_return(mock_grade_span_expectation)
      get :edit, :id => "37"
      assigns[:grade_span_expectation].should equal(mock_grade_span_expectation)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do

      it "should expose a newly created grade_span_expectation as @grade_span_expectation" do
        RiGse::GradeSpanExpectation.should_receive(:new).with({'these' => 'params'}).and_return(mock_grade_span_expectation(:save => true))
        post :create, :grade_span_expectation => {:these => 'params'}
        assigns(:grade_span_expectation).should equal(mock_grade_span_expectation)
      end

      it "should redirect to the created grade_span_expectation" do
        RiGse::GradeSpanExpectation.stub!(:new).and_return(mock_grade_span_expectation(:save => true))
        post :create, :grade_span_expectation => {}
        response.should redirect_to(ri_gse_grade_span_expectation_url(mock_grade_span_expectation))
      end

    end

    describe "with invalid params" do

      it "should expose a newly created but unsaved grade_span_expectation as @grade_span_expectation" do
        RiGse::GradeSpanExpectation.stub!(:new).with({'these' => 'params'}).and_return(mock_grade_span_expectation(:save => false))
        post :create, :grade_span_expectation => {:these => 'params'}
        assigns(:grade_span_expectation).should equal(mock_grade_span_expectation)
      end

      it "should re-render the 'new' template" do
        RiGse::GradeSpanExpectation.stub!(:new).and_return(mock_grade_span_expectation(:save => false))
        post :create, :grade_span_expectation => {}
        response.should render_template('new')
      end

    end

  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested grade_span_expectation" do
        RiGse::GradeSpanExpectation.should_receive(:find).with("37").and_return(mock_grade_span_expectation)
        mock_grade_span_expectation.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :grade_span_expectation => {:these => 'params'}
      end

      it "should expose the requested grade_span_expectation as @grade_span_expectation" do
        RiGse::GradeSpanExpectation.stub!(:find).and_return(mock_grade_span_expectation(:update_attributes => true))
        put :update, :id => "1"
        assigns(:grade_span_expectation).should equal(mock_grade_span_expectation)
      end

      it "should redirect to the grade_span_expectation" do
        RiGse::GradeSpanExpectation.stub!(:find).and_return(mock_grade_span_expectation(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(ri_gse_grade_span_expectation_url(mock_grade_span_expectation))
      end

    end

    describe "with invalid params" do

      it "should update the requested grade_span_expectation" do
        RiGse::GradeSpanExpectation.should_receive(:find).with("37").and_return(mock_grade_span_expectation)
        mock_grade_span_expectation.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :grade_span_expectation => {:these => 'params'}
      end

      it "should expose the grade_span_expectation as @grade_span_expectation" do
        RiGse::GradeSpanExpectation.stub!(:find).and_return(mock_grade_span_expectation(:update_attributes => false))
        put :update, :id => "1"
        assigns(:grade_span_expectation).should equal(mock_grade_span_expectation)
      end

      it "should re-render the 'edit' template" do
        RiGse::GradeSpanExpectation.stub!(:find).and_return(mock_grade_span_expectation(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested grade_span_expectation" do
      RiGse::GradeSpanExpectation.should_receive(:find).with("37").and_return(mock_grade_span_expectation)
      mock_grade_span_expectation.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "should redirect to the grade_span_expectations list" do
      RiGse::GradeSpanExpectation.stub!(:find).and_return(mock_grade_span_expectation(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(grade_span_expectations_url)
    end
  end
end
