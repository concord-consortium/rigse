require 'spec_helper'
describe Embeddable::DataCollector do
  before(:each) do
  end

  it_should_behave_like 'a cloneable model'
  it "should create a new instance given valid attributes" do
    data_collector = Embeddable::DataCollector.new
    data_collector.save 
    data_collector.probe_type.should_not be_nil
    data_collector.should be_valid
  end
  
  it "it should not create a new instance without referencing an existing probe_type" do
    data_collector = Embeddable::DataCollector.new
    data_collector.probe_type = nil
    data_collector.save
    data_collector.probe_type.should be_nil
    data_collector.should_not be_valid
    data_collector = Embeddable::DataCollector.new
    data_collector.probe_type_id = 9999
    data_collector.save
    data_collector.should_not be_valid
  end
  
end
