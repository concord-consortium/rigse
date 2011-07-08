require 'spec_helper'

describe "/admin_tags/edit.html.erb" do
  include Admin::TagsHelper

  before(:each) do
    assigns[:tags] = @tags = stub_model(Admin::Tag,
      :new_record? => false,
      :scope => "value for scope",
      :tag => "value for tag"
    )
  end

  it "renders the edit tags form" do
    render

    response.should have_tag("form[action=#{tags_path(@tags)}][method=post]") do
      with_tag('input#tags_scope[name=?]', "tags[scope]")
      with_tag('input#tags_tag[name=?]', "tags[tag]")
    end
  end
end
