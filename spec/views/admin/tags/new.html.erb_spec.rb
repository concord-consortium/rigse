require 'spec_helper'

describe "/admin_tags/new.html.erb" do
  include Admin::TagsHelper

  before(:each) do
    assigns[:tags] = stub_model(Admin::Tag,
      :new_record? => true,
      :scope => "value for scope",
      :tag => "value for tag"
    )
  end

  it "renders new tags form" do
    render

    response.should have_tag("form[action=?][method=post]", admin_tags_path) do
      with_tag("input#tags_scope[name=?]", "tags[scope]")
      with_tag("input#tags_tag[name=?]", "tags[tag]")
    end
  end
end
