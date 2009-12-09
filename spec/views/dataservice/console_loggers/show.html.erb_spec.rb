require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/dataservice_console_loggers/show.html.erb" do
  include Dataservice::ConsoleLoggersHelper
  before(:each) do
    assigns[:console_logger] = @console_logger = stub_model(Dataservice::ConsoleLogger)
  end

  it "renders attributes in <p>" do
    pending "Broken example"
    render
  end
end
