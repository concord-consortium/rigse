require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/dataservice_console_loggers/index.html.erb" do
  include Dataservice::ConsoleLoggersHelper

  before(:each) do
    assigns[:dataservice_console_loggers] = [
      stub_model(Dataservice::ConsoleLogger),
      stub_model(Dataservice::ConsoleLogger)
    ]
  end

  it "renders a list of dataservice_console_loggers" do
    render
  end
end
