require 'spec_helper'
  def mock_probe_type(_opts = {})
    defaults = {
      :name => "type a", 
      :id => 2, 
      :unit => "fako units",
      :min => 0,
      :max => 10
    }
    opts = defaults.merge(_opts)
    return mock_model(Probe::ProbeType, opts)
  end
describe Embeddable::DataCollector do

  describe "When there are existing probes" do
    before(:all) do
      @fake_probe = mock_probe_type({:name => 'fake', :id => 1})
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

    describe "Embeddable::DataCollector.get_prototype" do
      it "should find and use an existing datacollector prototype with a known probeType" do
        @fake_probe_a = mock_probe_type
        moc_data_collector = mock_model(Embeddable::DataCollector, :probe_type => @fake_probe_a)
        prototypes = mock(:find => moc_data_collector)
        Embeddable::DataCollector.stub(:prototypes => prototypes)

        proto = Embeddable::DataCollector.get_prototype({:probe_type => @fake_probe_a, :graph_type => 'Sensor'})
        proto.probe_type.should == @fake_probe_a
      end
      
      it "should create a datacollector with the given probeType, when an existing prototype cant be found" do
        @fake_probe_a = mock_probe_type
        prototypes = mock(:find => nil)
        Embeddable::DataCollector.stub(:prototypes => prototypes)
        proto = Embeddable::DataCollector.get_prototype({:probe_type => @fake_probe_a, :graph_type => 'Sensor'})
        proto.probe_type.should == @fake_probe_a
      end

      it "should use the name of the probeType for the name of the dataCollector when making a new prototype" do
        @fake_probe_a = mock_probe_type
        prototypes = mock(:find => nil)
        Embeddable::DataCollector.stub(:prototypes => prototypes)
        proto = Embeddable::DataCollector.get_prototype({:probe_type => @fake_probe_a, :graph_type => 'Sensor'})
        proto.probe_type.should == @fake_probe_a
        proto.name.should match @fake_probe_a.name
      end
    end

  end

  describe "When no probes exist" do
    # todo: whats the behavior here?
    before(:each) do
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
      pending("it isn't clear what should happen here")
      data_collector.errors.on(:probe_type).should include(Embeddable::DataCollector::MISSING_PROBE_MESSAGE)
    end
  end

  describe "Dyanimcally updating name and axis properties when changing probe type" do
    before(:each) do
      @inital_probe_type = mock_probe_type(:name => 'initial_probe_type', :id => 1)
      @initial_name  = "initial name"
      @initial_units = "initial units"
      @initial_params = {
        :name  => @initial_name,
        :y_axis_units  => @initial_units,
        :y_axix_min    =>  0,
        :y_axis_max    =>  1,
        :initial_probe_type => @initial_probe_type
      }
      @alternate_probe_type = mock_probe_type(:name => "specometer", :id => 3, :units => 'specatrons', :min => 100.0, :max => 101.0)
      @data_collector = Embeddable::DataCollector.create
    end

    describe "When the probe_type changes by itself" do
      before(:each) do
        @data_collector.probe_type = @alternate_probe_type
        @data_collector.save
      end

      it "Should update the name property of the data collector when the probe_type changes" do
        @data_collector.name.should match @alternate_probe_type.name
      end
      
      it "Should update the y_axis_label property when the probe_type changes" do
        @data_collector.y_axis_label.should match @alternate_probe_type.name
      end
      
      it "should update the y_axis_units property when the probe_type changes" do
        @data_collector.y_axis_units.should match @alternate_probe_type.unit
      end
      
      it "should update the y_axis_min property when the probe_type changes" do
        @data_collector.y_axis_min.should be @alternate_probe_type.min
      end

      it "should update the y_axis_max property when the probe_type changes" do
        @data_collector.y_axis_max.should be @alternate_probe_type.max
      end
    end
    
    describe "when the probe_type changes, and dynimic fields are set by hand too" do
      before(:each) do
        @stringP = "something new"
        @numericP = 1234566.0
      end
      it "Should use the manually set name property even when the probe_type changes" do
        @data_collector.name = @stringP
        @data_collector.probe_type = @alternate_probe_type
        @data_collector.save!
        @data_collector.name.should be @stringP
      end

      it "Should use the manually set the y_axis_label even when the probe_type changes" do
        @data_collector.y_axis_label = @stringP
        @data_collector.probe_type = @alternate_probe_type
        @data_collector.save
        @data_collector.y_axis_label.should be @stringP
      end

      it "should use the manually set the y_axis_units even when the probe_type changes" do
        @data_collector.y_axis_units = @stringP
        @data_collector.probe_type = @alternate_probe_type
        @data_collector.save
        @data_collector.y_axis_units.should be @stringP
      end

      it "should use the manually set the y_axis_min even when the probe_type changes" do
        @data_collector.y_axis_min = @numericP
        @data_collector.probe_type = @alternate_probe_type
        @data_collector.save
        @data_collector.y_axis_min.should be @numericP
      end

      it "should use the manually set the y_axis_max even when the probe_type changes" do
        @data_collector.y_axis_max = @numericP
        @data_collector.probe_type = @alternate_probe_type
        @data_collector.save
        @data_collector.y_axis_max.should be @numericP
      end
    end
  end
end
