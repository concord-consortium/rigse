require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/unifying_themes/index.html.erb" do
  include UnifyingThemesHelper
  
  before(:each) do
    assigns[:unifying_themes] = [
      stub_model(UnifyingTheme),
      stub_model(UnifyingTheme)
    ]
  end

  it "should render list of unifying_themes" do
    render "/unifying_themes/index.html.erb"
  end
end

