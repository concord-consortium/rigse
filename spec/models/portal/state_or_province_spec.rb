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
    expect(Portal::StateOrProvince.configured.length).to eq(Portal::StateOrProvince::STATES_AND_PROVINCES.length)
  end

  it "should return no states if nil is configured" do
    APP_CONFIG[:states_and_provinces] = nil
    expect(Portal::StateOrProvince.configured).to be_empty
  end

  it "should return the specific states if they are configured" do
    APP_CONFIG[:states_and_provinces] = ['MA', 'RI']
    expect(Portal::StateOrProvince.configured).to eq(['MA', 'RI'])
  end

end
