require 'spec_helper'

describe "/admin/tags/edit.html.haml" do
  include Admin::TagsHelper

  before(:each) do
    power_user = stub_model(User, :has_role? => true)
    template.stub!(:current_user).and_return(power_user)
    assigns[:admin_tag] = @admin_tag = stub_model(Admin::Tag,
      :new_record? => false,
      :scope => "value for scope",
      :tag => "value for tag"
    )
  end

  it "renders the edit tags form" do
    render

    rendered.should have_tag("form[action=#{admin_tag_path(@admin_tag)}][method=post]") do
      with_tag('input#admin_tag_scope[name=?]', "admin_tag[scope]")
      with_tag('input#admin_tag_tag[name=?]', "admin_tag[tag]")
    end
  end
end
