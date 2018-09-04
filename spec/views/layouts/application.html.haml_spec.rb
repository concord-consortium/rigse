require 'spec_helper'

describe "rendering application.html.haml" do
  let(:fake_visitor) { Factory(:user, {id: 101,}) }
  let(:roles) {['first-role']}

  before do
    allow(view).to receive(:current_visitor).and_return(fake_visitor)
    allow(view).to receive(:current_user).and_return(fake_visitor)
    # allow(view).to receive(:calpicker_includes).and_return('')
    allow(fake_visitor).to receive(:authenticate).and_return(true)
    allow(fake_visitor).to receive(:role_names).and_return(roles)
  end

  it "applies the correct role classes" do
    assign(:original_user, fake_visitor)
    render(
      :text => "nothing",
      :layout => "layouts/application"
    )
    expect(rendered).to have_selector("body.first-role-visitor")
  end
end
