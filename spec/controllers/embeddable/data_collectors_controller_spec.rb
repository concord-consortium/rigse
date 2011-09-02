require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::DataCollectorsController do
  render_views

  describe "using its own datastore" do
    # @see ./spec/support/embeddable_controller_helper.rb
    it_should_behave_like 'an embeddable controller'
    def with_tags_like_an_otml_data_collector
      with_tag('OTDataCollector') do
        with_tag('source') do
          with_tag('OTDataGraphable') do
            with_tag('dataProducer')
          end
        end
        with_tag('xDataAxis') do
          with_tag('OTDataAxis')
        end
        with_tag('yDataAxis') do
          with_tag('OTDataAxis')
        end
      end
    end
  end

  describe "the data store for a prediction graph" do
    before(:all) do
      generate_default_project_and_jnlps_with_mocks
      generate_portal_resources_with_mocks
    end
    before(:each) do
      @mock_table = mock_model(Embeddable::DataTable,
        :is_numeric? => true,
        :precision => 2,
        :id => 1024,
        :name => 'table')
      @graph = Embeddable::DataCollector.create(
        :graph_type_id => Embeddable::DataCollector::PREDICTION)
    end

    describe "with a data_table" do
      before(:each) do
        @graph.stub!(:data_table => @mock_table)
      end
      it "should get its data from the data_tables dataStore" do
        Embeddable::DataCollector.should_receive(:find).with("37").and_return(@graph)
        get :show, :id => "37", :format => 'otml'
        response.should have_tag('dataStore') do
          with_tag("object[refid*=?]", /data_store_data_table/)
        end
      end
    end

    describe "without a data_table" do
      before(:each) do
        @graph.stub!(:data_table => nil)
      end
      it "should get its data from the data_tables dataStore" do
        Embeddable::DataCollector.should_receive(:find).with("37").and_return(@graph)
        get :show, :id => "37", :format => 'otml'
        response.should have_tag('dataStore') do
          # <OTDataStore local_id='data_store_data_collector_3046' numberChannels='2'>
          with_tag("OTDataStore[local_id*=?]", /data_store_data_collector_/ )
        end
      end
    end
  end

  describe "digital display only" do
    before(:all) do
      generate_default_project_and_jnlps_with_mocks
      generate_portal_resources_with_mocks
    end
    before(:each) do
      @font_size = 23
      @graph = Embeddable::DataCollector.create(
        :is_digital_display => true,
        :dd_font_size => @font_size)
      Embeddable::DataCollector.should_receive(:find).and_return(@graph)
    end
    describe "the generated otml" do
      it "should include OTDigitalDisplay tag" do
        get :show, :id => "37", :format => 'otml'
        response.should have_tag("OTDigitalDisplay[fontSize='#{@font_size}']")
      end
    end
  end
end
