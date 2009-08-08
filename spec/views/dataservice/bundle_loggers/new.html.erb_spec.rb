require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/dataservice_bundle_loggers/new.html.erb" do
  include Dataservice::BundleLoggersHelper

  before(:each) do
    assigns[:bundle_logger] = stub_model(Dataservice::BundleLogger,
      :new_record? => true
    )
  end

  it "renders new bundle_logger form" do
    render

    response.should have_tag("form[action=?][method=post]", dataservice_bundle_loggers_path) do
    end
  end
end
