require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/dataservice_console_loggers/new.html.erb" do
  include Dataservice::ConsoleLoggersHelper

  before(:each) do
    assigns[:console_logger] = stub_model(Dataservice::ConsoleLogger,
      :new_record? => true
    )
  end

  it "renders new console_logger form" do
    render

    response.should have_tag("form[action=?][method=post]", dataservice_console_loggers_path) do
    end
  end
end
