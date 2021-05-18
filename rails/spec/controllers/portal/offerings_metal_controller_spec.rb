require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::OfferingsMetalController, type: :request do
  describe "GET launch_status" do
    it "should return 'Not Found' without a user" do
      offering = FactoryBot.create(:portal_offering)
      get "/portal/offerings/#{offering.id}/launch_status.json", params: {}
      expect(response.body).to eq("Not Found")
    end

    it "should return no_session with a user not running anything" do
      learner = FactoryBot.create(:full_portal_learner)
      # this is used instead of sign_in since this is a request test and it is not available as a helper in that context
      get "/login/#{learner.student.user.login}", params: {}
      get "/portal/offerings/#{learner.offering.id}/launch_status.json", params: {}
      response.media_type == 'application/json'
      json_body = JSON.parse(response.body)
      expect(json_body['event_type']).to eq('no_session')
    end
  end
end
