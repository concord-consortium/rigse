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

  describe "digital displays" do
    describe "font size" do
      describe "validation" do
        describe "a font size of zero" do
          it "should not be valid" do
            Embeddable::DataCollector.create(:dd_font_size => 0).should_not be_valid
          end
        end
        describe "a font size of 304" do
          it "should not be valid" do
            Embeddable::DataCollector.create(:dd_font_size => 304).should_not be_valid
          end
        end
        describe "a font size of 40" do
          it "should be valid" do
            Embeddable::DataCollector.create(:dd_font_size => 40).should be_valid
          end
        end
      end
      
      describe "pre-defined sizes for authors" do
        it "should include a small font" do
          Embeddable::DataCollector.dd_font_sizes[:small].should_not be_nil
        end
        it "should include a medium font" do
          Embeddable::DataCollector.dd_font_sizes[:medium].should_not be_nil
        end
        it "should include a large font" do
          Embeddable::DataCollector.dd_font_sizes[:large].should_not be_nil
        end
      end
      
      describe "the default digital display font-size" do
        it "should be small" do
          digital = Embeddable::DataCollector.create(:is_digital_display => true)
          digital.dd_font_size.should == Embeddable::DataCollector.dd_font_sizes[:small]
        end
      end

    end
  end

  describe "x axis conversion" do
    it "should convert values when saving and the x axis units are minutes" do
      dc = Embeddable::DataCollector.new
      dc.x_axis_units = "min"
      dc.x_axis_min_converted = 3600
      dc.x_axis_min.should == 60
      dc.x_axis_max_converted = 1800
      dc.x_axis_max.should == 30
    end

    it "should convert values when reading and the x axis units are minutes" do
      dc = Embeddable::DataCollector.new
      dc.x_axis_units = "min"
      dc.x_axis_min = 22
      dc.x_axis_max = 16
      dc.x_axis_min_converted.should == 1320
      dc.x_axis_max_converted.should == 960
    end
  end
end
