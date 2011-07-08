require 'spec_helper'

describe "/admin_tags/show.html.erb" do
  include Admin::TagsHelper
  before(:each) do
    assigns[:tags] = @tags = stub_model(Admin::Tag,
      :scope => "value for scope",
      :tag => "value for tag"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ scope/)
    response.should have_text(/value\ for\ tag/)
  end
end
