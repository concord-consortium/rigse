require 'spec_helper'
describe Embeddable::Diy::Sensor do
  def create(attributes)
    Embeddable::Diy::Sensor.create(attributes)
  end

  before(:all) do
    @backed_proto = Factory(:data_collector)
    @mock_proto = mock_model(Embeddable::DataCollector)
  end    
  
  before(:each) do
    @valid_attributes={
      :prototype => @backed_proto,
    }
  end
  it_should_behave_like 'an embeddable'

  describe "field validations" do
    it "should create a new instance given valid attributes" do
      test_case = create(@valid_attributes)
      test_case.should be_valid
    end
  end

  describe "proxying to the prototype datacollector " do
    it "should not proxy for id or user or user_id, or pages" do
      test_case = create(@valid_attributes.update(:user => Factory(:user)))
      test_case.id.should_not be_nil
      @backed_proto.id.should_not be_nil
      test_case.id.should_not == @backed_proto.id
      test_case.user.should_not be_nil
      @backed_proto.user.should be_nil
      page = Factory(:page)
      test_case.pages << page
      test_case.should have(1).pages
      @backed_proto.should have(0).pages
    end
  end

  describe "updating associated prediction graph" do
    it "should update the prediction y axis label after prototype is changed" do
      @predict = create(:prototype => Factory(:data_collector), :graph_type => 'Prediction')
      @sensor = create(:prototype => Factory(:data_collector, :probe_type => Factory(:probe_type, :name => "My Sensor")), :graph_type => 'Sensor')
      @sensor.prediction_graph_source = @predict
      @sensor.save
      @predict.data_collector.y_axis_label.should == "My Sensor"
      @predict.data_collector.title.should == "My Sensor Data Collector"
    end
  end
end
