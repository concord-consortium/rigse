require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/dataservice_console_contents/edit.html.erb" do
  include Dataservice::ConsoleContentsHelper

  before(:each) do
    assigns[:console_content] = @console_content = stub_model(Dataservice::ConsoleContent,
      :new_record? => false,
      :body => "value for body"
    )
  end

  it "renders the edit console_content form" do
    pending "Broken example"
    render

    response.should have_tag("form[action=#{console_content_path(@console_content)}][method=post]") do
      with_tag('textarea#console_content_body[name=?]', "console_content[body]")
    end
  end
end
