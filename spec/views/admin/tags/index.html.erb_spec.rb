require 'spec_helper'

describe "/admin/tags/index.html.haml" do
  include Admin::TagsHelper

  before(:each) do
    power_user = stub_model(User, :has_role? => true)
    template.stub!(:current_user).and_return(power_user)
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
    pending "Make this test compatible with pagination"
    render
    response.should have_tag("tr>td", "value for scope".to_s, 2)
    response.should have_tag("tr>td", "value for tag".to_s, 2)
  end
end
