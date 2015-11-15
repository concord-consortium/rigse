require "spec_helper"

describe "when user visits landing page and then signs in" do
  let(:user) { Factory.create(:confirmed_user) }
  let(:project) { Factory.create(:project, landing_page_slug: "foo-proj", landing_page_content: "<h1>Foo</h1>") }

  it "should be redirected back to the landing page" do
    get project.landing_page_slug
    expect(response).to render_template("landing_page")
    post "/users/sign_in", user: {login: user.login, password: user.password}
    expect(response).to redirect_to("/#{project.landing_page_slug}")
  end
end