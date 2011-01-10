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

    it "should proxy for things like 'name', 'description', &etc." do
      test_case = create(@valid_attributes)
      test_case.description.should_not be_nil 
      test_case.description.should == @backed_proto.description
      test_case.name.should_not be_nil 
      test_case.name.should == @backed_proto.name
    end

    it "should respond_to? for proxied attributes" do
      test_case = create(@valid_attributes)
      test_case.should respond_to :description
      test_case.should respond_to :name
    end

  end
  
  describe "simple serialized fields" do
    it "accept arbitrary asignment into the customizations field" do
      cust = {
        :one => 1,
        :two => "two",
        :three => :four }
      bad = { :bad => :values }
      test_case = create(@valid_attributes.update(:customizations => cust))
      test_case.should be_valid
      test_case.id.should_not be_nil 
      test_case.reload
      test_case.customizations.should == cust
      test_case.customizations.should_not == bad
    end
  end

  describe "method_missing serilialization" do
    it "should let customizations be saved in customization field" do
      test_case = create(@valid_attributes)
      test_case.x_axis_max = 100
      test_case.customizations.should_not be_nil
      test_case.save
      test_case.reload
      test_case.customizations.should have_key :x_axis_max
    end

   it "should allow customizable fields to be addressed as properties" do
      test_case = create(@valid_attributes)
      test_case.x_axis_min = 0
      test_case.x_axis_max = 100
      test_case.save
      test_case.reload
      test_case.x_axis_min.should == 0
      test_case.x_axis_max.should == 100
    end

  end
end
