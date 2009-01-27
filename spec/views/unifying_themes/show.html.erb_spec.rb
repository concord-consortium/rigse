require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/unifying_themes/show.html.erb" do
  include UnifyingThemesHelper
  
  before(:each) do
    assigns[:unifying_theme] = @unifying_theme = stub_model(UnifyingTheme)
  end

  it "should render attributes in <p>" do
    render "/unifying_themes/show.html.erb"
  end
end

