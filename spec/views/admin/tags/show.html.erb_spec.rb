require 'spec_helper'

describe "/admin/tags/show.html.haml" do
  include Admin::TagsHelper
  before(:each) do
    power_user = stub_model(User, :has_role? => true)
    template.stub!(:current_user).and_return(power_user)
    assigns[:admin_tag] = @admin_tag = stub_model(Admin::Tag,
      :scope => "value for scope",
      :tag => "value for tag",
      :id => 42
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ scope/)
    response.should have_text(/value\ for\ tag/)
  end
end
