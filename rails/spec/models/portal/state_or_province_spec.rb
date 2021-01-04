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



  # TODO: auto-generated
  describe '.from_districts' do
    it 'from_districts' do
      result = described_class.from_districts

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.state_and_province_abbreviations' do
    it 'state_and_province_abbreviations' do
      result = described_class.state_and_province_abbreviations

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.configured' do
    it 'configured' do
      result = described_class.configured

      expect(result).not_to be_nil
    end
  end


end
