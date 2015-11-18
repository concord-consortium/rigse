require "spec_helper"

describe "when user signs in and 'after_sign_in_path' parameter is provided" do
  let(:user) { Factory.create(:confirmed_user) }
  let(:custom_url) { "/some-foo-bar-path" }

  it "user is redirected back to this page" do
    post "/users/sign_in", user: {login: user.login, password: user.password}, after_sign_in_path: custom_url
    expect(response).to redirect_to(custom_url)
  end
end
