require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/dataservice_console_contents/show.html.erb" do
  include Dataservice::ConsoleContentsHelper
  before(:each) do
    assigns[:console_content] = @console_content = stub_model(Dataservice::ConsoleContent,
      :body => "value for body"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ body/)
  end
end
