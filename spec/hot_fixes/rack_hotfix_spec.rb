require File.expand_path('../../spec_helper', __FILE__)

describe "config/initializers/rack_hotfix.rb" do
  it "should not include the rack_hotfix.rb initializer after upgrading to rack 1.3.0" do
    (Gem.loaded_specs["rack"].version <=> Gem::Version.create("1.3")).should eq -1
  end
end