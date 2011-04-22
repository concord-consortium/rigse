#require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'spec_helper'
describe ItsiImporter do
  before(:all) do
  end
  # def process_diy_activity_section(actvity,diy_act,section_key,section_name,section_description)
  describe "process diy activity section" do
    before(:each) do
      @sections = []
      @activity = mock_model(Activity,
          :investigation => mock_model(Investigation, :update_attribute => true),
          :user => mock_model(User))
      @diy_act = mock_model(Itsi::Activity,
          :collectdata => "Collect Data Rich text",
          :update_attribute => true,
          :uuid => '5693A069-B829-47BF-9BF0-30FBFDA9F7E2',
          :puiblic => true,
          :probe_type_id => nil)
      @section_key = "collect_data"
      @section_name = "Collect Data"
      @section_description = "go out there and get me some data!"
    end

    def call_process_diy_activity_section(key=@section_key)
      section_def = ItsiImporter::SECTIONS_MAP.find {|i| i[:key] == :collectdata}
      ItsiImporter.process_diy_activity_section(@activity,@diy_act, section_def)
    end

    it "should respond to the method named process_diy_activity_section" do
      ItsiImporter.should respond_to :process_diy_activity_section
    end

    it "should add a section and a page to the activity that are well named" do
      @activity.should_receive(:sections).and_return(@sections)
      call_process_diy_activity_section
      @sections.should have(1).section
      @sections.first.should be_an_instance_of Section
      @sections.first.name.should be @section_name
    end

    it "should create appropriate embeddedables" do
      @activity.should_receive(:sections).and_return(@sections)
      @diy_act.should_receive(:respond_to?).with(:collect_data_text_response).and_return(true)
      @diy_act.should_receive(:respond_to?).with(:collect_data_drawing_response).and_return(true)
      #@diy_act.should_receive(:respond_to?).with(:probe_type_id).and_return(true)
      @diy_act.should_receive(:respond_to?).with(:collect_data_probetype_id).and_return(true)
      Embeddable::DataCollector.stub!(:get_prototype => Factory(:data_collector))
      # respond with these answers:
      @diy_act.should_receive(:collect_data_drawing_response).and_return(false)
      @diy_act.should_receive(:collect_data_text_response).and_return(true)
      #@diy_act.should_receive(:collectdata1_calibration_active).and_return(true)
      #@diy_act.should_receive(:collectdata1_calibration_id).and_return(1)
      @diy_act.should_receive(:collect_data_calibration_active).and_return(true)
      @diy_act.should_receive(:collect_data_calibration_id).and_return(1)
      @diy_act.should_receive(:collect_data_probe_active ).and_return(true)
      #@diy_act.should_receive(:probe).and_return(1)
      @diy_act.should_receive(:collect_data_probetype_id).and_return(1)

      # dont handle these types:
      @diy_act.should_receive(:respond_to?).with(:collect_data_model_active).and_return(false)
      call_process_diy_activity_section
      page = @sections.first.pages.first
      # should have a diy:section, a diy:sensor, and a drawing_response
      page.should have(3).page_elements
      # but the drawing_response is disabled:
      page.page_elements.select{ |e| e.is_enabled}.should have(2).enabled
    end

  end

  describe "create_activity_from_itsi_activity method" do
    def call_create_activity(act = @itsi_activity, user = @user)
      ItsiImporter.create_activity_from_itsi_activity(act,user)
    end

    before(:each) do
      Itsi::Activity.stub!(:find)
      @itsi_activity = mock_model(Itsi::Activity,
        :name => "fake diy activity",
        :description => "fake diy activity",
        :uuid => '7A46C23E-EB9B-4C59-AC78-842A021237A3',
        :public => true
      )
      @user = mock_model(User,
        :login => "fake_user",
        :first_name => "fake",
        :last_name => "user",
        :name => "fake user",
        :add_role => true
      )
      @roll = mock_model(Role,
        :quoted_id => '1'
      )
      Role.stub!(:find_by_title).and_return(@roll)
    end

    it "should respond to create_activity_from_itsi_activity" do
      ItsiImporter.should respond_to :create_activity_from_itsi_activity
    end

    it "should try to create all the required sections" do
      Itsi::Activity.should_receive(:find).and_return(@itsi_activity)
      expected_calls = ItsiImporter::SECTIONS_MAP.size
      ItsiImporter::SECTIONS_MAP.map{ |e| e[:key] }.each do |key|
        @itsi_activity.should_receive(key).and_return("some text")
        # no extra elements:
        [ :text_response,:drawing_response,:graph_response,
          :model_active, :probe_active, :prediction_graph, :prediction_draw, :prediction_text].each do |attribute|
          attribute_key = ItsiImporter.attribute_name_for(key,attribute)
          if attribute_key
            @itsi_activity.should_receive(attribute_key).and_return(false)
          end
        end
      end
      ItsiImporter.create_activity_from_itsi_activity("1",@user)
    end

    describe "defined exception types" do
      errors = %w[ MissingUuid BadModel BadActivity BadUser ValidationError]
      errors.each do |error_name|
        it "should define #{error_name}" do
          clazz = "ItsiImporter::#{error_name}".constantize
          msg = "testing"
          opts = {:testing => true}
          instance = clazz.new(opts)
          instance.should_not be_nil
          instance.should respond_to :options
          instance.should respond_to :message
          instance.options[:testing].should == true
        end
      end
    end


    #end
    #describe "reporting on an import do" do
      #it "should create a report buffer"
      #it "should report the total number of itsi activities in the diy"
      #it "should report on how many itsi activities are going to be imported"
      #it "should report on itsi activities have been imported in the past"
      #it "should report on itsi models that have been imported in the past"
      #it "should report any error with model types"
      #it "should report any errors with models"
      #it "should report any errors with activities"
      #it "should log any exception"
      #it "should report on any activities that were not imported"
      ## DIY
    #end
  end
end
