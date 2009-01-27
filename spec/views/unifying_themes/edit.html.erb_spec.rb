require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/unifying_themes/edit.html.erb" do
  include UnifyingThemesHelper
  
  before(:each) do
    assigns[:unifying_theme] = @unifying_theme = stub_model(UnifyingTheme,
      :new_record? => false
    )
  end

  it "should render edit form" do
    render "/unifying_themes/edit.html.erb"
    
    response.should have_tag("form[action=#{unifying_theme_path(@unifying_theme)}][method=post]") do
    end
  end
end


