require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/dataservice_console_contents/index.html.erb" do
  include Dataservice::ConsoleContentsHelper

  before(:each) do
    assigns[:dataservice_console_contents] = [
      stub_model(Dataservice::ConsoleContent,
        :body => "value for body"
      ),
      stub_model(Dataservice::ConsoleContent,
        :body => "value for body"
      )
    ]
  end

  it "renders a list of dataservice_console_contents" do
    render
    response.should have_tag("tr>td", "value for body".to_s, 2)
  end
end
