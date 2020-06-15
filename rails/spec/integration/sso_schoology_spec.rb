require "spec_helper"

describe "when the user signs in with Schoology" do
  # the schoology environment variables are set in spec_helper
  let(:oauth_request_token) { "abbcd" }
  let(:oauth_token_secret) { "secrete_abcd" }
  let(:oauth_access_token) { "access_abbcd" }

  def stub_oauth_request(url: nil,
                         body: "",
                         token: nil,
                         include_callback: false,
                         callback_params: nil)
    callback_url = "http%3A%2F%2Fwww.example.com%2Fusers%2Fauth%2Fschoology%2Fcallback"
    if(callback_params)
      callback_url += CGI.escape("?#{callback_params}")
    end

    stub_request(:get, url).
    with(
      headers: {
        'Accept'=>'*/*',
        'Authorization'=> %r{
          OAuth[ ]
          #{include_callback ? "oauth_callback=\"#{callback_url}\",[ ]" : "" }
          oauth_consumer_key="1234",[ ]
          oauth_nonce="[^"]*",[ ]
          oauth_signature="[^"]*",[ ]
          oauth_signature_method="HMAC-SHA1",[ ]
          oauth_timestamp="\d*",[ ]
          #{token ? "oauth_token=\"#{token}\",[ ]" : "" }
          oauth_version="1.0"
        }x
      }).
    to_return(status: 200, body: body, headers: {})
  end

  context "on initial request" do
    let(:callback_params) { nil }
    let(:callback_url) { "http://www.example.com/users/auth/schoology/callback" }
    let!(:token_stub) {
      stub_oauth_request(
        url: "https://api.schoology.com/v1/oauth/request_token",
        body: "oauth_token=#{oauth_request_token}&oauth_token_secret=#{oauth_token_secret}",
        include_callback: true,
        callback_params: callback_params
      )
    }

    # this uses the following let variables:
    #   url - the url to request
    #   callback_url - the url sent to schoology which it should redirect to
    #   callback_params - if set these are added to the calback_url
    #   oauth_request_token - the token sent to schoology
    shared_examples "redirects correctly to schoology" do
      it "redirects to schoology" do
        get url
        if callback_params
          full_callback_url = "#{callback_url}?#{callback_params}"
        else
          full_callback_url = callback_url
        end
        redirect_url = "https://app.schoology.com/oauth/authorize?" +
          {
            oauth_callback: full_callback_url,
            oauth_token: oauth_request_token
          }.to_query

        expect(response).to redirect_to(redirect_url)
        expect(token_stub).to have_been_requested
      end
    end

    context "with a basic url" do
      let(:url) { "/users/auth/schoology" }
      include_examples "redirects correctly to schoology"
    end

    context "with a simple parameter in the url" do
      let(:callback_params) { "fancy=one" }
      let(:url) { "/users/auth/schoology?#{callback_params}" }
      include_examples "redirects correctly to schoology"
    end
    context "with a complex parameter in the url" do
      let(:after_sign_in_path) { "/somewhere?redirect=https%3A%2F%2Fconcord.org" }
      let(:callback_params) { "after_sign_in_path=#{CGI.escape(after_sign_in_path)}" }
      let(:url) { "/users/auth/schoology?#{callback_params}" }
      include_examples "redirects correctly to schoology"
    end
  end

  context "on callback request" do
    let(:callback_params) { nil }

    let!(:token_stub) {
      # without callback_confirmed:
      stub_oauth_request(
        url: "https://api.schoology.com/v1/oauth/access_token",
        body: "oauth_token=#{oauth_access_token}",
        token: oauth_request_token,
        include_callback: true,
        callback_params: callback_params
      )
    }

    let!(:user_stub) {
      stub_oauth_request(
        url: "https://api.schoology.com/v1/users/me",
        body: {
          uid: "1234",
          primary_email: "fake@example.com",
          name_first: "Fake",
          name_last: "User"
        }.to_json,
        token: oauth_access_token
      )
    }

    before(:each) {
      # add some expections to prevent silent failures
      expect_any_instance_of(OmniAuth::Strategy).to_not receive(:fail!)
      expect(User).to receive(:find_for_omniauth).and_call_original
      expect_any_instance_of(AuthenticationsController).to receive(:sign_in_and_redirect).and_call_original

      # configure the session as if it was setup during the initial response
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
    }
    context "with a basic callback" do
      it "redirects to users normal page" do
        get "/users/auth/schoology/callback"

        expect(token_stub).to have_been_requested
        expect(user_stub).to have_been_requested

        expect(response).to redirect_to("/getting_started")
      end
    end

    context "when the callback contains a simple after_sign_in_path param" do
      let(:callback_params) { "after_sign_in_path=#{CGI.escape("/somewhere")}" }

      it "redirects to the after_sign_in_path" do
        get "/users/auth/schoology/callback?#{callback_params}"

        expect(token_stub).to have_been_requested
        expect(user_stub).to have_been_requested

        expect(response).to redirect_to("/somewhere?redirecting_after_sign_in=1")
      end
    end
    context "when the callback contains a complex after_sign_in_path param" do
      let(:after_sign_in_path) { "/somewhere?redirect=https%3A%2F%2Fconcord.org" }
      let(:callback_params) { "after_sign_in_path=#{CGI.escape(after_sign_in_path)}" }

      it "redirects to the after_sign_in_path" do
        get "/users/auth/schoology/callback?#{callback_params}"

        expect(token_stub).to have_been_requested
        expect(user_stub).to have_been_requested

        expect(response).to redirect_to("#{after_sign_in_path}&redirecting_after_sign_in=1")
      end
    end
  end
end
