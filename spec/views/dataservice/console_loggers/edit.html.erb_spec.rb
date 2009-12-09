require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/dataservice_console_loggers/edit.html.erb" do
  include Dataservice::ConsoleLoggersHelper

  before(:each) do
    assigns[:console_logger] = @console_logger = stub_model(Dataservice::ConsoleLogger,
      :new_record? => false
    )
  end

  it "renders the edit console_logger form" do
    pending "Broken example"
    render

    response.should have_tag("form[action=#{console_logger_path(@console_logger)}][method=post]") do
    end
  end
end
