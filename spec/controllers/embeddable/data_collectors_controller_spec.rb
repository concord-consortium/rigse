require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::DataCollectorsController do
  render_views

  describe "using its own datastore" do
    # @see ./spec/support/embeddable_controller_helper.rb
    it_should_behave_like 'an embeddable controller'
    def with_tags_like_an_otml_data_collector
      assert_select('OTDataCollector') do
        assert_select('source') do
          assert_select('OTDataGraphable') do
            assert_select('dataProducer')
          end
        end
        assert_select('xDataAxis') do
          assert_select('OTDataAxis')
        end
        assert_select('yDataAxis') do
          assert_select('OTDataAxis')
        end
      end
    end
  end

  describe "the data store for a prediction graph" do
    before(:each) do
      generate_default_project_and_jnlps_with_mocks
      generate_portal_resources_with_mocks
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
        assert_select('dataStore') do
          assert_select("object[refid*=?]", /data_store_data_table/)
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
        assert_select('dataStore') do
          # <OTDataStore local_id='data_store_data_collector_3046' numberChannels='2'>
          assert_select("OTDataStore[local_id*=?]", /data_store_data_collector_/ )
        end
      end
    end
  end

  describe "digital display only" do
    before(:each) do
      generate_default_project_and_jnlps_with_mocks
      generate_portal_resources_with_mocks
      @font_size = 23
      @graph = Embeddable::DataCollector.create(
        :is_digital_display => true,
        :dd_font_size => @font_size)
      Embeddable::DataCollector.should_receive(:find).and_return(@graph)
    end
    describe "the generated otml" do
      it "should include OTDigitalDisplay tag" do
        get :show, :id => "37", :format => 'otml'
        assert_select("OTDigitalDisplay[fontSize='#{@font_size}']")
      end
    end
  end

  describe "with multiple_graphable_enabled" do
    include OtmlHelper
    before(:each) do
      generate_default_project_and_jnlps_with_mocks
      generate_portal_resources_with_mocks
    end
    before(:each) do
      @graph = Embeddable::DataCollector.create(
        :multiple_graphable_enabled =>  true)
      Embeddable::DataCollector.should_receive(:find).and_return(@graph)
    end
    describe "the generated otml" do
      it "should include a prototype graphable" do
        get :show, :id => "37", :format => 'otml'
        assert_select("prototypeGraphables")
        #%OTSensorDataProxy{ :local_id => ot_local_id_for(data_collector, :data_proxy, extra) }
        prototype_id = ot_local_id_for(@graph, :data_proxy, :prototype) 
        local_id = ot_local_id_for(@graph, :data_proxy) 
        assert_select("OTSensorDataProxy[local_id='#{prototype_id}']")
        assert_select("OTSensorDataProxy[local_id='#{local_id}']")
      end
    end
  end

  describe "without multiple_graphable_enabled" do
    include OtmlHelper
    before(:each) do
      generate_default_project_and_jnlps_with_mocks
      generate_portal_resources_with_mocks
    end
    before(:each) do
      @graph = Embeddable::DataCollector.create(
        :multiple_graphable_enabled =>  false)
      Embeddable::DataCollector.should_receive(:find).and_return(@graph)
    end
    describe "the generated otml" do
      it "should include a prototype graphable" do
        get :show, :id => "37", :format => 'otml'
        #%OTSensorDataProxy{ :local_id => ot_local_id_for(data_collector, :data_proxy, extra) }
        prototype_id = ot_local_id_for(@graph, :data_proxy, :prototype) 
        local_id = ot_local_id_for(@graph, :data_proxy) 
        assert_select("OTSensorDataProxy[local_id='#{prototype_id}']",false)
        assert_select("OTSensorDataProxy[local_id='#{local_id}']")
      end
    end

  end
end
