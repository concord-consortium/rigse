require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/images/index.html.haml" do

  before(:each) do
    assigns[:images] = @images = [
      stub_model(Image),
      stub_model(Image)
    ]
    @user = mock(
      :has_role?       => true
    )
    view.stub!(:current_visitor).and_return(@user)
  end

  it "should render list of images without error" do
    render
  end
end

