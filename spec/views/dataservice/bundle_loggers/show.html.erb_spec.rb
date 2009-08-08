require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/dataservice_bundle_loggers/show.html.erb" do
  include Dataservice::BundleLoggersHelper
  before(:each) do
    assigns[:bundle_logger] = @bundle_logger = stub_model(Dataservice::BundleLogger)
  end

  it "renders attributes in <p>" do
    render
  end
end
