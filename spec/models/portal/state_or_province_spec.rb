require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::StateOrProvince do
  before(:each) do
    @old_configuration = APP_CONFIG[:states_and_provinces]
  end

  after(:each) do
    APP_CONFIG[:states_and_provinces] = @old_configuration
  end

  it "should return all states if :all is configured" do
    APP_CONFIG[:states_and_provinces] = 'all'
    Portal::StateOrProvince.configured.length.should == Portal::StateOrProvince::STATES_AND_PROVINCES.length
  end

  it "should return no states if nil is configured" do
    APP_CONFIG[:states_and_provinces] = nil
    Portal::StateOrProvince.configured.should be_empty
  end

  it "should return the specific states if they are configured" do
    APP_CONFIG[:states_and_provinces] = ['MA', 'RI']
    Portal::StateOrProvince.configured.should == ['MA', 'RI']
  end

end
