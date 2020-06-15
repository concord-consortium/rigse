require "spec_helper"

describe "when user signs in with a Google" do
  # the google environment variables are set in spec_helper
  # it doesn't work mocking them here

  let(:callback_code) { "uhyza" }

  let(:token_stub) {
    stub_request(:post, "https://accounts.google.com/o/oauth2/token").
    with(
      body: {
        "client_id"=>"1234", "client_secret"=>"1234",
        "code"=>callback_code,
        "grant_type"=>"authorization_code",
        "redirect_uri"=>"http://www.example.com/users/auth/google/callback"},
      headers: {
        'Accept'=>'*/*',
        'Content-Type'=>'application/x-www-form-urlencoded',
      }).
    to_return(status: 200,
      body: '{"access_token":"fake_token"}',
      headers: { 'Content-Type'=>'application/json'})
  }

  let(:userinfo_stub) {
    stub_request(:get, "https://www.googleapis.com/oauth2/v1/userinfo").
    with(
      headers: {
        'Accept'=>'*/*',
        'Authorization'=>'Bearer fake_token'
      }).
    to_return(status: 200,
      body: {
          id: "123",
          name: "Fake User",
          verified_email: true,
          email: "fake@example.com",
          given_name: "Fake",
          family_name: "User"
        }.to_json,
      headers: { 'Content-Type'=>'application/json'})
  }

  context "on initial request" do
    let (:state_param_value) { nil }
    let (:redirect_url) {
      "https://accounts.google.com/o/oauth2/auth?" +
        "access_type=offline&client_id=1234" +
        "&redirect_uri=http%3A%2F%2Fwww.example.com%2Fusers%2Fauth%2Fgoogle%2Fcallback" +
        "&response_type=code" +
        "&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.profile+" +
        "https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email" +
        ( state_param_value ? "&state=#{state_param_value}" : "" )
    }
    context "with a basic url" do
      it "redirects to google" do
        get "/users/auth/google"
        expect(response).to redirect_to(redirect_url)
      end
    end

    # we don't need this this behavior, this test just confirms how things work
    context "with a url containing simple state" do
      let (:state_param_value) { "some_fake_state" }
      it "redirects to google with that state" do
        get "/users/auth/google?state=#{state_param_value}"
        expect(response).to redirect_to(redirect_url)
      end
    end
    # we don't need this this behavior, this test just confirms how things work
    context "with a url containing urlencoded state" do
      let (:state_param_value) { CGI.escape "https://concord.org" }
      it "redirects to google with that state still encoded" do
        get "/users/auth/google?state=#{state_param_value}"
        expect(response).to redirect_to(redirect_url)
      end
    end

    context "with a url containing after_sign_in_path" do
      let (:after_sign_in_path) { "/redirect/back/somewhere/else" }
      let (:state_param_value) { CGI.escape("after_sign_in_path=#{after_sign_in_path}") }
      it "redirects to google with the state set to after_still encoded" do
        get "/users/auth/google?after_sign_in_path=#{CGI.escape(after_sign_in_path)}"
        expect(response).to redirect_to(redirect_url)
      end
    end

    # we don't need this this exact behavior, but this test is a useful proxy for when
    # we update the omniauth-google-oauth2 since it will be setting state internally
    # most likely this test will break since the state will be a random string
    context "with a url containing after_sign_in_path and state" do
      let (:after_sign_in_path) { "/redirect/back/somewhere/else" }
      let (:request_state_param) { "blahblah" }
      let (:state_param_value) { CGI.escape("#{request_state_param} after_sign_in_path=#{after_sign_in_path}") }
      it "redirects to google with the state set to after_still encoded" do
        get "/users/auth/google?state=#{request_state_param}&after_sign_in_path=#{CGI.escape(after_sign_in_path)}"
        expect(response).to redirect_to(redirect_url)
      end
    end
  end

  context "on the callback request" do
    before(:each) {
      # setup the necessary stubs
      token_stub
      userinfo_stub

      # setup some basic expectations to make sure we don't fail silently
      expect_any_instance_of(OmniAuth::Strategy).to_not receive(:fail!)
      expect(User).to receive(:find_for_omniauth).and_call_original
      expect_any_instance_of(AuthenticationsController).to receive(:sign_in_and_redirect).and_call_original
    }

    context "when no state has been passed" do
      it "redirects to users normal page" do
        get "/users/auth/google/callback?code=#{callback_code}"

        expect(response).to redirect_to("/getting_started")
        expect(token_stub).to have_been_requested
        expect(userinfo_stub).to have_been_requested
      end
    end
    context "when state with an after_sign_in_path been passed" do
      let(:state_param) { "after_sign_in_path=/somewhere" }
      # TODO: we need to set the state environment variable because this request
      # will be checking it in the newer versions of the gems

      it "redirects to the after_sign_in_path" do
        get "/users/auth/google/callback?code=#{callback_code}" +
          "&state=#{CGI.escape(state_param)}"

        expect(response).to redirect_to("/somewhere?redirecting_after_sign_in=1")
        expect(token_stub).to have_been_requested
        expect(userinfo_stub).to have_been_requested
      end
    end
    context "when state with a complex after_sign_in_path been passed" do
      let(:state_param) { "after_sign_in_path=/somewhere?redirect=https%3A%2F%2Fconcord.org" }
      # TODO: we need to set the state environment variable because this request
      # will be checking it in the newer versions of the gems

      it "redirects to the after_sign_in_path" do
        get "/users/auth/google/callback?code=#{callback_code}" +
          "&state=#{CGI.escape(state_param)}"

        expect(response).to redirect_to("/somewhere?redirect=https%3A%2F%2Fconcord.org&redirecting_after_sign_in=1")
        expect(token_stub).to have_been_requested
        expect(userinfo_stub).to have_been_requested
      end
    end
    context "when state with a complex after_sign_in_path and random prefix been passed " do
      let(:state_param) { "a4aienviase after_sign_in_path=/somewhere?redirect=https%3A%2F%2Fconcord.org" }
      # TODO: we need to set the state environment variable because this request
      # will be checking it in the newer versions of the gems

      it "redirects to the after_sign_in_path" do
        get "/users/auth/google/callback?code=#{callback_code}" +
          "&state=#{CGI.escape(state_param)}"

        expect(response).to redirect_to("/somewhere?redirect=https%3A%2F%2Fconcord.org&redirecting_after_sign_in=1")
        expect(token_stub).to have_been_requested
        expect(userinfo_stub).to have_been_requested
      end
    end
  end
end
