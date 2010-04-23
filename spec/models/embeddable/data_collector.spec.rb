require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Embeddable::DataCollector do
  before(:each) do

  end

  it "should create a new instance given valid attributes" do
    data_collector = Embeddable::DataCollector.create(
      {:probe_type => Factory(:probe_type)}
    )
    data_collector.save 
    data_collector.probe_type.should_not be_nil
    data_collector.should be_valid
  end
  
  it "it should not create a new instance with missing fields" do
    data_collector = Embeddable::DataCollector.create()
    data_collector.save
    data_collector.probe_type.should be_nil
    data_collector.should_not be_valid
  end
  
end
