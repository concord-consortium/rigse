require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/unifying_themes/new.html.erb" do
  include UnifyingThemesHelper
  
  before(:each) do
    assigns[:unifying_theme] = stub_model(UnifyingTheme,
      :new_record? => true
    )
  end

  it "should render new form" do
    render "/unifying_themes/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", unifying_themes_path) do
    end
  end
end


