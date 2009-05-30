require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/maven_jnlp_icons/new.html.erb" do
  include MavenJnlp::IconsHelper
  
  before(:each) do
    assigns[:icon] = stub_model(MavenJnlp::Icon,
      :new_record? => true,
      :uuid => "value for uuid",
      :name => "value for name",
      :href => "value for href",
      :height => 1,
      :width => 1
    )
  end

  it "renders new icon form" do
    render
    
    response.should have_tag("form[action=?][method=post]", maven_jnlp_icons_path) do
      with_tag("input#icon_uuid[name=?]", "icon[uuid]")
      with_tag("input#icon_name[name=?]", "icon[name]")
      with_tag("input#icon_href[name=?]", "icon[href]")
      with_tag("input#icon_height[name=?]", "icon[height]")
      with_tag("input#icon_width[name=?]", "icon[width]")
    end
  end
end


