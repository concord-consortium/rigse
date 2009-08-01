require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/dataservice_bundle_loggers/index.html.erb" do
  include Dataservice::BundleLoggersHelper

  before(:each) do
    assigns[:dataservice_bundle_loggers] = [
      stub_model(Dataservice::BundleLogger),
      stub_model(Dataservice::BundleLogger)
    ]
  end

  it "renders a list of dataservice_bundle_loggers" do
    render
  end
end
