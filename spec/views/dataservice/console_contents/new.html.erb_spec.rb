require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/dataservice_console_contents/new.html.erb" do
  include Dataservice::ConsoleContentsHelper

  before(:each) do
    assigns[:console_content] = stub_model(Dataservice::ConsoleContent,
      :new_record? => true,
      :body => "value for body"
    )
  end

  it "renders new console_content form" do
    pending "Broken example"
    render

    response.should have_tag("form[action=?][method=post]", dataservice_console_contents_path) do
      with_tag("textarea#console_content_body[name=?]", "console_content[body]")
    end
  end
end
