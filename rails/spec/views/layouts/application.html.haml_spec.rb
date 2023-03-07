require 'spec_helper'

describe "rendering application.html.haml" do
  let(:fake_visitor) { FactoryBot.create(:user, {id: 101}) }
  let(:fake_admin_settings) { FactoryBot.create(:admin_settings, {sitewide_alert: nil}) }
  let(:roles) {['first-role']}

  before do
    allow(view).to receive(:current_visitor).and_return(fake_visitor)
    allow(view).to receive(:current_user).and_return(fake_visitor)
    allow(view).to receive(:current_settings).and_return(fake_admin_settings)
    allow(fake_visitor).to receive(:authenticate).and_return(true)
    allow(fake_visitor).to receive(:role_names).and_return(roles)
  end

  it "applies the correct role classes" do
    assign(:original_user, fake_visitor)
    render(
      :html => "nothing",
      :layout => "layouts/application"
    )
    expect(rendered).to have_selector("body.first-role-visitor")
  end

  it "hides the main nav for guests" do
    allow(view).to receive(:current_user).and_return(nil)
    render(
      :html => "nothing",
      :layout => "layouts/application"
    )
    expect(rendered).to have_selector("body.main-nav-hidden")
  end

  it "applies the correct theme classes" do
    set_theme_env('learn')
    render(
      :html => "nothing",
      :layout => "layouts/application"
    )
    expect(rendered).to have_selector("body.learn-theme-styles")

    set_theme_env('foo')
    render(
      :html => "nothing",
      :layout => "layouts/application"
    )
    expect(rendered).to have_selector("body.foo-theme-styles")
  end
end
