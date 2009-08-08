require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/dataservice_bundle_loggers/edit.html.erb" do
  include Dataservice::BundleLoggersHelper

  before(:each) do
    assigns[:bundle_logger] = @bundle_logger = stub_model(Dataservice::BundleLogger,
      :new_record? => false
    )
  end

  it "renders the edit bundle_logger form" do
    render

    response.should have_tag("form[action=#{bundle_logger_path(@bundle_logger)}][method=post]") do
    end
  end
end
