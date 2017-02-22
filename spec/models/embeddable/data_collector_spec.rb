require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::DataCollector do
  before(:each) do

  end

  it "should create a new instance given valid attributes" do
    data_collector = Embeddable::DataCollector.new
    data_collector.save 
    expect(data_collector.probe_type).not_to be_nil
    expect(data_collector).to be_valid
  end
  
  it "it should not create a new instance without referencing an existing probe_type" do
    data_collector = Embeddable::DataCollector.new
    data_collector.probe_type = nil
    data_collector.probe_type_id = 9999
    data_collector.save
    expect(data_collector).not_to be_valid
  end

  it "might optionally use a data_table for a datastore" do
    data_table = Embeddable::DataTable.create
    data_collector = Embeddable::DataCollector.create
    expect(data_collector.data_table).to be_nil
    expect(data_collector).to be_valid
    data_collector.data_table = data_table
    data_collector.save
    data_collector.reload
    expect(data_collector.data_table_id).to eq(data_table.id)
    expect(data_collector).to be_valid
  end

  describe "graph_types" do
    before(:each) do
      @data_collector = Embeddable::DataCollector.create
    end

    describe "constants" do
      it "don't change without breaking test" do
        expect(Embeddable::DataCollector::SENSOR_ID).to eq(1)
        expect(Embeddable::DataCollector::PREDICTION_ID).to eq(2)
      end
    end

    describe "graph_type methods" do
      it "graph_type_id should assign for valid types" do
        @data_collector.graph_type= Embeddable::DataCollector::SENSOR
        @data_collector.save
        @data_collector.reload
        expect(@data_collector.graph_type).to eq(Embeddable::DataCollector::SENSOR)
        @data_collector.graph_type= Embeddable::DataCollector::PREDICTION
        @data_collector.save
        @data_collector.reload
        expect(@data_collector.graph_type).to eq(Embeddable::DataCollector::PREDICTION)
      end

      it "graph_type_id should not assign for invalid types" do
        old_value = @data_collector.graph_type
        @data_collector.graph_type="xyzzy"
        expect(@data_collector.graph_type).to eq(old_value)
      end
    end
  end

  describe "digital displays" do
    describe "font size" do
      describe "validation" do
        describe "a font size of zero" do
          it "should not be valid" do
            expect(Embeddable::DataCollector.create(:dd_font_size => 0)).not_to be_valid
          end
        end
        describe "a font size of 304" do
          it "should not be valid" do
            expect(Embeddable::DataCollector.create(:dd_font_size => 304)).not_to be_valid
          end
        end
        describe "a font size of 40" do
          it "should be valid" do
            expect(Embeddable::DataCollector.create(:dd_font_size => 40)).to be_valid
          end
        end
      end
      
      describe "pre-defined sizes for authors" do
        it "should include a small font" do
          expect(Embeddable::DataCollector.dd_font_sizes[:small]).not_to be_nil
        end
        it "should include a medium font" do
          expect(Embeddable::DataCollector.dd_font_sizes[:medium]).not_to be_nil
        end
        it "should include a large font" do
          expect(Embeddable::DataCollector.dd_font_sizes[:large]).not_to be_nil
        end
      end
      
      describe "the default digital display font-size" do
        it "should be small" do
          digital = Embeddable::DataCollector.create(:is_digital_display => true)
          expect(digital.dd_font_size).to eq(Embeddable::DataCollector.dd_font_sizes[:small])
        end
      end

    end
  end
end
