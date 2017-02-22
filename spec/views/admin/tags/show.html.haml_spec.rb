require 'spec_helper'

describe "/admin/tags/show.html.haml" do
  include Admin::TagsHelper
  before(:each) do
    power_user = stub_model(User, :has_role? => true)
    allow(view).to receive(:current_visitor).and_return(power_user)
    @admin_tag = stub_model(Admin::Tag,
      :scope => "value for scope",
      :tag => "value for tag")
    assign(:admin_tag, @admin_tag)
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/value for scope/)
    expect(rendered).to match(/value for tag/)
  end
end
