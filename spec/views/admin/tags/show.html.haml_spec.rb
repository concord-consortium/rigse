require 'spec_helper'

describe "/admin/tags/show.html.haml" do
  include Admin::TagsHelper
  before(:each) do
    power_user = stub_model(User, :has_role? => true)
    view.stub!(:current_user).and_return(power_user)
    @admin_tag = stub_model(Admin::Tag,
      :scope => "value for scope",
      :tag => "value for tag")
    assign(:admin_tag, @admin_tag)
  end

  it "renders attributes in <p>" do
    render
    rendered.should match(/value for scope/)
    rendered.should match(/value for tag/)
  end
end
