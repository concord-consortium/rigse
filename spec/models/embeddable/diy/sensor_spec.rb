require 'spec_helper'
describe Embeddable::Diy::Sensor do
  def create(attributes)
    Embeddable::Diy::Sensor.create(attributes)
  end

  before(:all) do
    @prediction = Factory(:data_collector)
    @backed_proto = Factory(:data_collector, :prediction_graph_id => @prediction.id)
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

  describe "copying the prototype datacollector " do
    before(:each) do
      @test_case = create(@valid_attributes.update(:user => Factory(:user)))
    end

    it "should not copy user_id" do
      @test_case.user_id.should_not == @backed_proto.user_id
    end
    it "should not copy uuid" do
      @test_case.uuid.should_not be_nil
      @test_case.uuid.should_not == @backed_proto.uuid
    end

    it "should not copy created_at" do
      @test_case.created_at.should_not == @backed_proto.created_at
    end

    it "should not copy updated_at" do
      @test_case.updated_at.should_not == @backed_proto.updated_at
    end
    it "should not copy prediction_graph_id" do
      @test_case.prediction_graph_id.should_not == @backed_proto.prediction_graph_id
    end

    it "should copy things like 'name', 'description', &etc." do
      @test_case.description.should == @backed_proto.description
      @test_case.name.should == @backed_proto.name
      @test_case.x_axis_label.should == @backed_proto.x_axis_label
      @test_case.y_axis_label.should == @backed_proto.y_axis_label
    end
  end
end
