require 'spec_helper'

describe "/admin_tags/index.html.erb" do
  include Admin::TagsHelper

  before(:each) do
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
    render
    response.should have_tag("tr>td", "value for scope".to_s, 2)
    response.should have_tag("tr>td", "value for tag".to_s, 2)
  end
end
