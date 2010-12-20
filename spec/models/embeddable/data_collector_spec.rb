require 'spec_helper'
describe Embeddable::DataCollector do
  
  describe "When there are existing probes" do
    before(:all) do
      @fake_probe= mock_model(Probe::ProbeType,
        :name => 'fake')
      Probe::ProbeType.stub!(:find_by_name => @fake_probe)
      Probe::ProbeType.stub!(:find => @fake_probe)
    end

    it_should_behave_like 'a cloneable model'
    it "should create a new instance given valid attributes" do
      data_collector = Embeddable::DataCollector.new
      data_collector.save 
      data_collector.probe_type.should_not be_nil
      data_collector.probe_type.id.should_not be_nil
      data_collector.should be_valid
    end
    
    it "should use a good default and valid probe_type" do
      data_collector = Embeddable::DataCollector.create
      data_collector.probe_type.should_not be_nil
      data_collector.should be_valid
    end

    it "should fail validation if the probe_type_id is wrong" do
      data_collector = Embeddable::DataCollector.new
      data_collector.probe_type_id = 9999
      data_collector.save
      data_collector.should_not be_valid
    end
  end
  
  describe "When no probes exist" do
    # todo: whats the behavior here?
    before(:all) do
      Probe::ProbeType.stub!(:find_by_name => nil)
      Probe::ProbeType.stub!(:find => nil)
      Probe::ProbeType.stub!(:default => nil)
    end
    
    it "should fail validation" do
      data_collector = Embeddable::DataCollector.create
      data_collector.should_not be_valid
    end

    it "Present a good validation message, and log the error" do
      data_collector = Embeddable::DataCollector.create
      data_collector.should_not be_valid
      data_collector.errors.on(:probe_type).should include(Embeddable::DataCollector::MISSING_PROBE_MESSAGE)
    end

  end
end
