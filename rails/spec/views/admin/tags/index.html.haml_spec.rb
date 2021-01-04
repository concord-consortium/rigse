require 'spec_helper'

describe "/admin/tags/index.html.haml" do
  include Admin::TagsHelper

  before(:each) do
    power_user = stub_model(User, :has_role? => true)
    allow(view).to receive(:current_visitor).and_return(power_user)
    assigns[:admin_tags] = [
      stub_model(Admin::Tag,
        :scope => "value for scope",
        :tag => "value for tag"
      ),
      stub_model(Admin::Tag,
        :scope => "value for scope",
        :tag => "value for tag"
      )
    ]
  end

  it "renders a list of admin_tags" do
    skip "Make this test compatible with pagination"
    render
    expect(response).to have_selector("tr>td", "value for scope".to_s, 2)
    expect(response).to have_selector("tr>td", "value for tag".to_s, 2)
  end
end
