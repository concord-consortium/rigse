require "spec_helper"

describe "when user signs in with a SSO provider" do
  describe "when the provider is Google" do
    # the google environment variables are set in spec_helper
    # it doesn't work mocking them here

    it "first redirects to google" do
      get "/users/auth/google"
      redirect_url = "https://accounts.google.com/o/oauth2/auth?" +
        "access_type=offline&client_id=1234&" +
        "redirect_uri=http%3A%2F%2Fwww.example.com%2Fusers%2Fauth%2Fgoogle%2Fcallback&" +
        "response_type=code&" +
        "scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.profile+" +
        "https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email"
      expect(response).to redirect_to(redirect_url)
    end

    it "then gets the callback request from google" do
      token_stub = stub_request(:post, "https://accounts.google.com/o/oauth2/token").
      with(
        body: {
          "client_id"=>"1234", "client_secret"=>"1234", "code"=>nil,
          "grant_type"=>"authorization_code",
          "redirect_uri"=>"http://www.example.com/users/auth/google/callback"},
        headers: {
          'Accept'=>'*/*',
          'Content-Type'=>'application/x-www-form-urlencoded',
        }).
      to_return(status: 200,
        body: '{"access_token":"fake_token"}',
        headers: { 'Content-Type'=>'application/json'})

      userinfo_stub = stub_request(:get, "https://www.googleapis.com/oauth2/v1/userinfo").
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

      expect_any_instance_of(OmniAuth::Strategy).to_not receive(:fail!)
      expect(User).to receive(:find_for_omniauth).and_call_original
      expect_any_instance_of(AuthenticationsController).to receive(:sign_in_and_redirect).and_call_original

      get "/users/auth/google/callback"

      expect(token_stub).to have_been_requested
      expect(userinfo_stub).to have_been_requested
    end
  end

  describe "when the provider is Schoology" do
    # the schoology environment variables are set in spec_helper
    let(:oauth_request_token) { "abbcd" }
    let(:oauth_token_secret) { "secrete_abcd" }
    let(:oauth_access_token) { "access_abbcd" }

    it "first redirects to schoology" do
      token_stub = stub_request(:get, "https://api.schoology.com/v1/oauth/request_token").
        with(
          headers: {
            'Accept'=>'*/*',
            'Authorization'=> %r{
              OAuth[ ]oauth_callback="http%3A%2F%2Fwww.example.com%2Fusers%2Fauth%2Fschoology%2Fcallback",[ ]
              oauth_consumer_key="1234",[ ]
              oauth_nonce="[^"]*",[ ]
              oauth_signature="[^"]*",[ ]
              oauth_signature_method="HMAC-SHA1",[ ]
              oauth_timestamp="\d*",[ ]
              oauth_version="1.0"
            }x
          }).
        to_return(status: 200,
          body: "oauth_token=#{oauth_request_token}&" +
            "oauth_token_secret=#{oauth_token_secret}",
          headers: {})

      get "/users/auth/schoology"
      redirect_url = "https://app.schoology.com/oauth/authorize?" +
        "oauth_callback=http%3A%2F%2Fwww.example.com%2Fusers%2Fauth%2Fschoology%2Fcallback&" +
        "oauth_token=#{oauth_request_token}"

      expect(response).to redirect_to(redirect_url)
      expect(token_stub).to have_been_requested
    end

    it "then gets the callback request from schoology" do
      expect_any_instance_of(OmniAuth::Strategy).to_not receive(:fail!)
      expect(User).to receive(:find_for_omniauth).and_call_original
      expect_any_instance_of(AuthenticationsController).to receive(:sign_in_and_redirect).and_call_original

      # it seems we are going to mock the session since this is counting on it to be
      # configured during the callback phase
      # session["oauth"] ||= {}
      # session["oauth"][name.to_s] = {"callback_confirmed" => request_token.callback_confirmed?, "request_token" => request_token.token, "request_secret" => request_token.secret}

      # there might be a better way to do this, but...
      allow_any_instance_of(OmniAuth::Strategies::OAuth).to receive(:session).and_return(
        {
          "oauth" => {
            "schoology" => {
              # it isn't clear if callback_confirmed is set when doing a real Schoology login
              # "callback_confirmed" => true,
              "request_token" => oauth_request_token,
              "request_secret" => oauth_token_secret
            }
          }
        }
      )

      # without callback_confirmed:
      token_stub = stub_request(:get, "https://api.schoology.com/v1/oauth/access_token").
      with(
        headers: {
          'Accept'=>'*/*',
          'Authorization'=> %r{
            OAuth[ ]oauth_callback="http%3A%2F%2Fwww.example.com%2Fusers%2Fauth%2Fschoology%2Fcallback",[ ]
            oauth_consumer_key="1234",[ ]
            oauth_nonce="[^"]*",[ ]
            oauth_signature="[^"]*",[ ]
            oauth_signature_method="HMAC-SHA1",[ ]
            oauth_timestamp="\d*",[ ]
            oauth_token="#{oauth_request_token}",[ ]
            oauth_version="1.0"
          }x
        }).
        to_return(status: 200, body: "oauth_token=#{oauth_access_token}", headers: {})


      user_stub = stub_request(:get, "https://api.schoology.com/v1/users/me").
      with(
        headers: {
          'Accept'=>'*/*',
          'Authorization'=> %r{
            OAuth[ ]oauth_consumer_key="1234",[ ]
            oauth_nonce="[^"]*",[ ]
            oauth_signature="[^"]*",[ ]
            oauth_signature_method="HMAC-SHA1",[ ]
            oauth_timestamp="\d*",[ ]
            oauth_token="#{oauth_access_token}",[ ]
            oauth_version="1.0"
          }x
        }).
      to_return(status: 200,
        body: {
          uid: "1234",
          primary_email: "fake@example.com",
          name_first: "Fake",
          name_last: "User"
        }.to_json,
        headers: {})

      get "/users/auth/schoology/callback"

      expect(token_stub).to have_been_requested
      expect(user_stub).to have_been_requested
    end

  end
end
