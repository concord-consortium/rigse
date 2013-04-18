require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::OfferingsMetalController do
  describe "GET launch_status" do
    it "should return 'Not Found' without a user" do
      offering = Factory(:portal_offering)
      get :launch_status, :id => offering.id
      response.body.should == "Not Found"
    end

    it "should return no_session with a user not running anything" do
      learner = Factory(:full_portal_learner)
      sign_in learner.student.user
      get :launch_status, :id => learner.offering.id
      response.content_type == 'application/json'
      json_body = JSON.parse(response.body)
      json_body['event_type'].should == 'no_session'
    end
  end
end