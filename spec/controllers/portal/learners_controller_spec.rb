require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::LearnersController do
  it "should render the config builder" do
  	@controller.stub!(:current_project).and_return(
  		mock(:project, 
  			:use_periodic_bundle_uploading? => false,
  			:use_student_security_questions => false,
  			:require_user_consent? => false)
  	)
  	learner = Factory(:full_portal_learner)
  	stub_current_user(learner.student.user)
  	get :show, :format => :config, :id => learner.id
  end


  it "should raise an exception when unauthorized config request is made" do
  	@controller.stub!(:current_project).and_return(
  		mock(:project, 
  			:use_periodic_bundle_uploading? => false,
  			:use_student_security_questions => false,
  			:require_user_consent? => false)
  	)
  	learner = Factory(:full_portal_learner)
  	lambda { 
  		get :show, :format => :config, :id => learner.id
  	}.should raise_error
  	
  end
end