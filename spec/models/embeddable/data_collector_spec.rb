require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::DataCollector do
  before(:each) do

  end

  it "should create a new instance given valid attributes" do
    data_collector = Embeddable::DataCollector.new
    data_collector.save 
    data_collector.probe_type.should_not be_nil
    data_collector.should be_valid
  end
  
  it "it should not create a new instance without referencing an existing probe_type" do
    data_collector = Embeddable::DataCollector.new
    data_collector.probe_type = nil
    data_collector.probe_type_id = 9999
    data_collector.save
    data_collector.should_not be_valid
  end

  it "might optionally use a data_table for a datastore" do
    data_table = Embeddable::DataTable.create
    data_collector = Embeddable::DataCollector.create
    data_collector.data_table.should be_nil
    data_collector.should be_valid
    data_collector.data_table = data_table
    data_collector.save
    data_collector.reload
    data_collector.data_table_id.should == data_table.id
    data_collector.should be_valid
  end

  describe "graph_types" do
    before(:each) do
      @data_collector = Embeddable::DataCollector.create
    end
    
    its "constants don't change without breaking test" do
      Embeddable::DataCollector::SENSOR_ID.should == 1
      Embeddable::DataCollector::PREDICTION_ID.should == 2
    end

    describe "graph_type methods" do
      it "graph_type_id should assign for valid types" do
        @data_collector.graph_type= Embeddable::DataCollector::SENSOR
        @data_collector.save
        @data_collector.reload
        @data_collector.graph_type.should == Embeddable::DataCollector::SENSOR
        @data_collector.graph_type= Embeddable::DataCollector::PREDICTION
        @data_collector.save
        @data_collector.reload
        @data_collector.graph_type.should == Embeddable::DataCollector::PREDICTION
      end

      it "graph_type_id should not assign for invalid types" do
        old_value = @data_collector.graph_type
        @data_collector.graph_type="xyzzy"
        @data_collector.graph_type.should == old_value
      end
    end
  end
end
