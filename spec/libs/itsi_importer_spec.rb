#require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'spec_helper'

class String
  def strip_tags
    ActionController::Base.helpers.strip_tags(self)
  end
end

describe ItsiImporter do
  before(:all) do
  end

  describe "find_or_import_itsi_user(diy_user)" do
    it "should create a new user if there isn't one"
    it "should return the existing itsi user if the user exists already"
  end
  describe "find_or_create_itsi_import_user" do
    it "should create a new user when there is none"
    it "should use the existing import user when it exists"
  end

  describe "find_or_create_itsi_activity_template" do
    it "should always create an activity with the appropriate sections"
  end

  describe "setup_prototype_data_collectors" do
    it "should run without error" do
      ItsiImporter.setup_prototype_data_collectors
    end
  end

  describe "delete_itsi_activity_template" do
    it "should delete the activity marked as the itsi activity template"
  end

  describe "create_activities_from_ccp_itsi_unit(ccp_itsi_unit, prefix="")" do
    it "should get a list of the activities from the portal for a given unit"
    it "should invoke create_activity_from_itsi_activity"
  end

  describe "create_activity_from_itsi_activity(foreign_key, user=nil, prefix="", use_number=false)" do

  end

  # there is a complex matrix for what attributes are named
  # in the DIY this method is suposed to help with that....
  # These names are pulled out of the diy schema file
  describe "attribute_name_for(section_key, attribute_name)" do
    expectations = {
      :probe_type_id                   => [:probetype_id,       :collectdata],
      :introduction_text_response      => [:text_response,      :introduction],
      :prediction_text_response        => [:prediction_text,    :predict],
      :prediction_graph_response       => [:prediction_graph,   :predict],
      :prediction_drawing_response     => [:drawing_response,   :prediction],
      :proced_text_response            => [:text_response,      :proced],
      :proced_drawing_response         => [:drawing_response,   :proced],
      :collectdata_text_response       => [:text_response,      :collectdata],
      :analysis_text_response          => [:text_response,      :analysis],
      :conclusion_text_response        => [:text_response,      :conclusion],
      :further_text_response           => [:text_response,      :further],
      :collectdata2_text_response      => [:text_response,     :collectdata2],
      :collectdata_probe_active        => [:probe_active,       :collectdata],
      :collectdata_model_active        => [:model_active,       :collectdata],
      :collectdata2_probe_active       => [:probe_active,       :collectdata2],
      :collectdata2_model_active       => [:model_active,       :collectdata2],
      :collectdata2_probetype_id       => [:probetype_id,       :collectdata2],
      :model_id                        => [:model_id,           :collectdata],
      :collectdata2_model_id           => [:model_id,           :collectdata2],
      :collectdata_probe_multi         => [:probe_multi,        :collectdata],
      :collectdata2_probe_multi        => [:probe_multi,        :collectdata2],
      :collectdata3_text_response      => [:text_response,      :collectdata3],
      :collectdata3_probe_active       => [:probe_active,       :collectdata3],
      :collectdata3_model_active       => [:model_active,       :collectdata3],
      :collectdata3_probe_multi        => [:probe_multi,        :collectdata3],
      :collectdata3_probetype_id       => [:probetype_id,       :collectdata3],
      :collectdata3_model_id           => [:model_id,           :collectdata3],
      :further_model_active            => [:model_active,       :further],
      :further_model_id                => [:model_id,           :further],
      :collectdata_drawing_response    => [:drawing_response,   :collectdata],
      :collectdata2_drawing_response   => [:drawing_response,   :collectdata2],
      :collectdata3_drawing_response   => [:drawing_response,   :collectdata3],
      :further_drawing_response        => [:drawing_response,   :further],
      :introduction_drawing_response   => [:drawing_response,   :introduction],
      :analysis_drawing_response       => [:drawing_response,   :analysis],
      :conclusion_drawing_response     => [:drawing_response,   :conclusion],
      :further_probe_active            => [:probe_active,       :further],
      :further_probetype_id            => [:probetype_id,       :further],
      :further_probe_multi             => [:probe_multi,        :further],
      :collectdata_graph_response      => [:prediction_graph,   :prediction2],
      :collectdata1_calibration_active => [:calibration_active, :collectdata],
      :collectdata1_calibration_id     => [:calibration_id,     :collectdata],
      :collectdata2_calibration_active => [:calibration_active, :collectdata2],
      :collectdata2_calibration_id     => [:calibration_id,     :collectdata2],
      :collectdata3_calibration_active => [:calibration_active, :collectdata3],
      :collectdata3_calibration_id     => [:calibration_id,     :collectdata3],
      :furtherprobe_calibration_active => [:calibration_active, :further],
      :furtherprobe_calibration_id     => [:calibration_id,     :further],
      :career_stem_text_response       => [:text_response,      :career_stem],
      :career_stem2_text_response      => [:text_response,      :career_stem2]
    }
    expectations.each_pair do |attribute_name,value|
      subsection,section = value
      result = ItsiImporter.attribute_name_for(section,subsection)
      result.should == attribute_name
    end
  end

  # only need to check one
  describe "attribute_for(activty,section_key,attribute)" do
    it "should return the attribute for the diy_activity, for a given section and subsection" do
      @diy_act = mock()
      @diy_act.should_receive(:furtherprobe_calibration_active).and_return(true)
      ItsiImporter.attribute_for(@diy_act,:further,:calibration_active).should be_true
    end
  end

  describe "model_id(activity,section_key)" do
    it "should return the model for a given section" do
      @diy_act = mock()
      @diy_act.should_receive(:collectdata2_model_active).and_return(true)
      @diy_act.should_receive(:collectdata2_model_id).and_return(1)
      ItsiImporter.model_id(@diy_act,:collectdata2).should == 1
    end
  end

  describe "prediction_graph(activity,section_key)" do
    it "should return the the prediction_graph for a given section" do
      @diy_act = mock()
      @diy_act.should_receive(:prediction_graph_response).and_return(true)
      ItsiImporter.prediction_graph(@diy_act,:predict).should be_true
    end
    it "should return nil when the section doesn't have a prediction graph" do
      @diy_act = mock()
      ItsiImporter.prediction_graph(@diy_act,:introduction).should be_nil
    end
  end

  describe "calibration_id(activity,section_key)" do
    it "should return the calibration for a given section with active calibrations" do
      @diy_act = mock()
      @diy_act.should_receive(:collectdata2_calibration_active).and_return(true)
      @diy_act.should_receive(:collectdata2_calibration_id).and_return(3)
      ItsiImporter.calibration_id(@diy_act,:collectdata2).should == 3
    end
    it "sound return nil when calibrations are not active" do
      @diy_act = mock()
      @diy_act.should_receive(:collectdata2_calibration_active).and_return(false)
      ItsiImporter.calibration_id(@diy_act,:collectdata2).should be_nil
    end
  end

  describe "set_embeddable(embeddable,symbol,value)" do
    it "set the value of an embeddable" do
      prototype_data_collector = mock 
      embeddable = mock 
      embeddable.should_receive(:prototype_data_collector=).with(prototype_data_collector)
      embeddable.should_receive(:enable)
      embeddable.should_receive(:pages).and_return([])
      #ItsiImporter.should_receive(:enable_section_for).with(embeddable)
      embeddable.should_receive(:save)
      ItsiImporter.set_embeddable(embeddable,:prototype_data_collector=,prototype_data_collector)
    end

  end

  describe "process_diy_activity_section(activity,diy_act,section_def)" do
    before(:all) do
      @diy_activity = mock
      @ativity = mock
      @element = {
        :key => :testing
      }
      @elements = [@element]
      @section_def = {
        :key => :testing,
        :embeddable_elements => @elements
      }
    end
    describe "when there is only an embeddable but no diy_attribute" do
      before(:all) do 
        @element[:embeddable] = true;
      end
      it "should log a warning" do
        ItsiImporter.should_receive(:log)
        ItsiImporter.should_not_receive(:process_testing)
        ItsiImporter.process_diy_activity_section(@activity,@diy_activity, @section_def)
      end
    end
    describe "when there is only a diy_attribute but no embeddable" do
      before(:all) do 
        @element[:diy_attribute] = true;
      end
      it "should log an error" do
        ItsiImporter.should_receive(:error)
        ItsiImporter.should_not_receive(:process_testing)
        ItsiImporter.process_diy_activity_section(@activity,@diy_activity, @section_def)
      end
    end
    describe "when there are both a diy_attribute and embeddable" do
      before(:all) do
        @element[:diy_attribute] = true;
        @element[:embeddable] = true;
      end
      it "should call the appropriate process_blah method" do
        ItsiImporter.should_receive(:process_testing).and_return(true)
        ItsiImporter.process_diy_activity_section(@activity,@diy_activity, @section_def)
      end
    end
  end

  describe "process_main_content(embeddable,diy_act,section_def)" do
    before (:each) do
      @diy_act = mock
      @embeddable = mock
      @introduction_text = "introduction text here"
      @processed_text,ignored = ItsiImporter.process_textile_content(@introduction_text)
      @section_def = {
        :key => :introduction,
        :embeddables => [
          :key => 'main_content',
          :embeddables => [@embeddable],
          :diy_attribute => true
        ]
      }
      #ItsiImporter.stub!(:enable_section_for)
    end
    it "should send the name of the section to get the content" do
      @diy_act.should_receive(:introduction).and_return @introduction_text
      @diy_act.should_receive(:textile).and_return false
      @embeddable.should_receive(:content=).with(@introduction_text)
      @embeddable.should_receive(:enable)
      @embeddable.should_receive(:save)
      @embeddable.should_receive(:pages).and_return([])
      ItsiImporter.process_main_content(@embeddable,@diy_act,@section_def)
    end
    it "should send the name of the section to get the textile content if textile is setup" do
      @diy_act.should_receive(:introduction).and_return @introduction_text
      @diy_act.should_receive(:textile).and_return true
      @embeddable.should_receive(:content=).with(@processed_text)
      @embeddable.should_receive(:enable)
      @embeddable.should_receive(:save)
      @embeddable.should_receive(:pages).and_return([])
      ItsiImporter.process_main_content(@embeddable,@diy_act,@section_def)
    end
    it "should set the embeddables 'has question' to true when text_response is true" do
      @diy_act.should_receive(:introduction).and_return @introduction_text
      @diy_act.should_receive(:textile).and_return false
      @embeddable.should_receive(:content=).with(@introduction_text)
      @embeddable.should_receive(:enable)
      @embeddable.should_receive(:save)
      @embeddable.should_receive(:pages).and_return([])
      ItsiImporter.process_main_content(@embeddable,@diy_act,@section_def)
    end
  end

  describe "process_probetype_id(embeddable,diy_act,section_def)" do
    before(:each) do
      @diy_act = mock
      @embeddable = mock
      @section_def = {
        :key => :collectdata,
        :embeddables => [
          :key => 'probe_id',
          :embeddables => [@embeddable],
          :diy_attribute => true
        ]
      }
      @probe_type = mock
      Probe::ProbeType.stub!(:find).and_return @probe_type
      @data_collector = mock
      Embeddable::DataCollector.stub!(:get_prototype).and_return(@data_collector)
    end
    it "should set the probe_prototype on the embeddable" do
      @calibration = mock
      @calibration.stub!(:id).and_return(3)
      Probe::Calibration.stub!(:find).and_return(@calibration)
      @diy_act.should_receive(:collectdata_probe_multi).and_return false
      @diy_act.should_receive(:collectdata_probe_active).and_return true
      @diy_act.should_receive(:probe_type_id).and_return 1
      @diy_act.should_receive(:collectdata1_calibration_active).and_return true
      @diy_act.should_receive(:collectdata1_calibration_id).and_return 3
      @embeddable.should_receive(:prototype=).with @data_collector
      @embeddable.should_receive(:enable)
      @embeddable.should_receive(:save)
      @embeddable.should_receive(:multiple_graphable_enabled=)
      @embeddable.should_receive(:pages).and_return([])
      ItsiImporter.process_probetype_id(@embeddable,@diy_act,@section_def)
    end
    it "should handle fake calibrations" do
      Probe::Calibration.should_not_receive(:find)
      @diy_act.should_receive(:collectdata_probe_multi).and_return false
      @diy_act.should_receive(:collectdata_probe_active).and_return true
      @diy_act.should_receive(:probe_type_id).and_return 7
      @diy_act.should_receive(:collectdata1_calibration_active).and_return true
      @diy_act.should_receive(:collectdata1_calibration_id).and_return 8
      @embeddable.should_receive(:prototype=).with @data_collector
      @embeddable.should_receive(:enable)
      @embeddable.should_receive(:save)
      @embeddable.should_receive(:multiple_graphable_enabled=)
      @embeddable.should_receive(:pages).and_return([])
      ItsiImporter.process_probetype_id(@embeddable,@diy_act,@section_def)
    end
  end

  describe "process_model_id(embeddable,diy_act,section_def)" do
    before(:each) do
      @diy_act = mock
      @embeddable = mock
      @section_def = {
        :key => :collectdata,
        :embeddables => [
          :key => 'model_id',
          :embeddables => [@embeddable],
          :diy_attribute => true
        ]
      }
      @itsi_model = mock
      @model = mock
      #ItsiImporter.stub!(:enable_section_for)
      Itsi::Model.stub!(:find).and_return @itsi_model
    end
    it "should set diy_model= on the embeddable" do
      Diy::Model.should_receive(:from_external_portal).with(@itsi_model).and_return(@model)
      @diy_act.should_receive(:collectdata_model_active).and_return true
      @diy_act.should_receive(:model_id).and_return 1
      @embeddable.should_receive(:diy_model=).with @model
      @embeddable.should_receive(:enable)
      @embeddable.should_receive(:save)
      @embeddable.should_receive(:pages).and_return([])
      ItsiImporter.process_model_id(@embeddable,@diy_act,@section_def)
    end
  end

  describe "process_prediction_graph(embeddable,diy_act,section_def)" do
    before(:each) do
      @diy_act = mock
      @embeddable = mock
      @section_def = {
        :key => :collectdata,
        :embeddables => [
          :key => 'prediction_graph',
          :embeddables => [@embeddable],
          :diy_attribute => true
        ]
      }
      @itsi_model = mock
      @model = mock
      Itsi::Model.stub!(:find).and_return @itsi_model
      #ItsiImporter.stub!(:enable_section_for)
    end
    it "should set diy_model= on the embeddable" do
      Diy::Model.should_receive(:from_external_portal).with(@itsi_model).and_return(@model)
      @diy_act.should_receive(:collectdata_model_active).and_return true
      @diy_act.should_receive(:model_id).and_return 1
      @embeddable.should_receive(:diy_model=).with @model
      @embeddable.should_receive(:enable)
      @embeddable.should_receive(:save)
      @embeddable.should_receive(:pages).and_return([])
      ItsiImporter.process_model_id(@embeddable,@diy_act,@section_def)
    end
  end

  describe "process_text_response(embeddable,diy_act,section_def)" do

  end

  describe "process_drawing_response(embeddable,diy_act,section_def)" do

  end

  describe "process_prediction_text(embeddable,diy_act,section_def)" do

  end

  describe "process_prediction_draw(embeddable,diy_act,section_def)" do

  end

  describe "log(message,level=1)" do

  end

  describe "error(message)" do

  end

  describe "start(diy_id)" do

  end

  describe "finish(activity)" do

  end

  describe "fail(exception, message)" do

  end

  describe "probetype_id(activity,section_key)" do
    before(:each) do
      @act = mock_model(Itsi::Activity)
    end
    it "should invoke :probe_type_id for the collect data section" do
      @act.should_receive(:collectdata_probe_active).and_return(true)
      @act.should_receive(:probe_type_id).and_return(1)
      ItsiImporter.probetype_id(@act,:collectdata).should == 1
    end
  end

  describe "make_activity" do
    before(:each) do
      @activity = ItsiImporter.make_activity
    end
    it "should make an activity with every section defined in SECTIONS_MAP" do
      expected_size = ItsiImporter::SECTIONS_MAP.size
      @activity.sections.size.should == expected_size
      @activity.sections.each_with_index do |section,index|
        section.name.should == ItsiImporter::SECTIONS_MAP[index][:name]
      end
    end
    it "by default all sections should be disabled except Introduction and Second Career STEM Question" do
      @activity.sections.each do |s|
        if s.name == 'Introduction' || s.name == 'Second Career STEM Question'
          s.is_enabled.should be_true
        else
          s.is_enabled.should be_false
        end
      end
    end
    
    it "by default the first sub section should be enabled and the rest disabled" do
      @activity.sections.each do |section|
        section.page_elements.each_with_index do |pe, index|
          if index == 0
            pe.is_enabled.should be_true
          else
            pe.is_enabled.should be_false
          end
        end
      end
    end
    
    describe "sensors created by the template" do
      before(:each) do
        @act = ItsiImporter.make_activity
      end
      it "should have all prediction sources set" do
        sections = ItsiImporter::SECTIONS_MAP.select {|e| [
          :collectdata, :collectdata2, :collectdata3, :further].include? e[:key] }
        sections.each do |section|
          elements = section[:embeddable_elements]
          prediction_graph = elements.find { |e| e[:key] === :prediction_graph}
          probetype = elements.find { |e| e[:key] === :probetype_id}
          #predict_emb = prediction_graph[:embeddable]
          probe_emb = probetype[:embeddable]
          # TODO: a better test would assert the prediction graph came
          # before..
          probe_emb.prediction_graph_source.should_not be_nil
        end
      end
    end
  end

  # def process_diy_activity_section(actvity,diy_act,section_key,section_name,section_description)
  describe "process diy activity section" do
    before(:each) do
      Embeddable::DataCollector.stub!(:get_prototype => Factory(:data_collector))
      @activity = ItsiImporter.make_activity
      @diy_rich_text= "Collect Data Rich Text from DIY"
      @diy_act = mock_model(Itsi::Activity,
          :collectdata                     => @diy_rich_text,
          :textile                         => true,
          :collectdata_text_response       => true,
          :collectdata_probe_active        => true,
          :collectdata_probe_multi         => true,
          :collectdata1_calibration_active => false,
          :collectdata_model_active        => false,
          :collectdata_drawing_response    => false,
          :probe_type_id                   => 1,
          :update_attribute                => true,
          :uuid                            => '5693A069-B829-47BF-9BF0-30FBFDA9F7E2',
          :puiblic                         => true)
      @section_key = :collectdata
      @section_name = "Collect Data"
      @section_description = "go out there and get me some data!"
    end

    def call_process_diy_activity_section(key=:collectdata)
      section_def = ItsiImporter::SECTIONS_MAP.find {|i| i[:key] == key}
      ItsiImporter.process_diy_activity_section(@activity,@diy_act, section_def)
    end

    it "should respond to the method named process_diy_activity_section" do
      ItsiImporter.should respond_to :process_diy_activity_section
    end

    it "The first embeddable element should be a diy section with content set" do
      call_process_diy_activity_section(:collectdata)
      section_def = ItsiImporter::SECTIONS_MAP.find {|i| i[:key] == @section_key}
      embeddables = section_def[:embeddable_elements].map {|e| e[:embeddable] }
      main_content = embeddables.first
      main_content.class.should == Embeddable::Diy::Section

      # xhtmls and open response are adding markup to all content
      # The following is a naive attempt to remove the noise to do a compare.
      main_content.content.strip_tags.should == @diy_rich_text.strip_tags
    end

    it "should create appropriate embeddedables" do
      call_process_diy_activity_section(:collectdata)
      map_entry = ItsiImporter::SECTIONS_MAP.find  {|sm| sm[:key] == :collectdata }
      map_index = ItsiImporter::SECTIONS_MAP.index {|sm| sm[:key] == :collectdata }

      section = @activity.sections[map_index]
      section.name.should == map_entry[:name]

      page = section.pages.first
      page.name.should == map_entry[:name]
      page.should have(map_entry[:embeddable_elements].size).page_elements
      page.page_elements.select{ |e| e.is_enabled}.should have(3).enabled
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
        :textile => true,
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
      ItsiImporter::SECTIONS_MAP.each do |section_map|
        key = section_map[:key]
        if (section_map[:embeddable_elements].any? { |e| e[:diy_attribute] and e[:key] == :main_content})
          @itsi_activity.should_receive(key).and_return("some text")
        end
        section_map[:embeddable_elements].each do |element|
          if element[:diy_attribute]
            attribute = element[:key]
            if attribute == :model_id
              attribute = :model_active
            elsif attribute == :probe_type_id
              attribute = :probe_active
            elsif attribute == :probetype_id
              attribute = :probe_active
            end
            attribute_key = ItsiImporter.attribute_name_for(key,attribute)
            if attribute_key
              @itsi_activity.should_receive(attribute_key).and_return(false)
            else
              #debugger
            end
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

    describe "importing units from the portal" do
      before(:each) do
        @unit_a = mock(:unit_name => 'unit a')
        @act_a = mock(:diy_identifier => 1)
        @act_a.stub_chain(:level, :level_name).and_return("Tests")
        @act_b = mock(:diy_identifier => 2)
        @act_b.stub_chain(:level, :level_name).and_return("Middle School")
      end
      it "should skip iporting certain units whose name starts with Test" do
        @unit_a.should_receive(:activities).and_return([@act_a, @act_b])
        ItsiImporter.should_not_receive(:create_activity_from_itsi_activity).with(1,nil,"")
        ItsiImporter.should_receive(:create_activity_from_itsi_activity).with(2,nil,"").and_return(nil)
        ItsiImporter.create_activities_from_ccp_itsi_unit(@unit_a)
      end
    end

    describe "remove_existing_activity" do
      before(:each) do
        @offering = mock
        @activity_with_offerings = mock( :offerings => [@offering], :name => "w/ offerings")
        @activity_without_offerings = mock( :offerings => [])
      end
      it "should destroy activities with no offerings" do
        @activity_without_offerings.should_receive(:destroy).and_return(true)
        ItsiImporter.remove_existing_activity(@activity_without_offerings)
      end

      # TODO isolate cases:
      it "should deactivate offerings of old activities (and other things)" do
        @activity_with_offerings.should_receive(:is_template=).with(false)
        @activity_with_offerings.should_receive(:public?).and_return(false)
        @activity_with_offerings.should_receive(:uuid=).and_return(true)
        @activity_with_offerings.should_receive(:generate_uuid).and_return(true)
        @activity_with_offerings.should_receive(:save).and_return(true)
        @activity_with_offerings.should_not_receive(:publish!)
        @offering.should_receive(:deactivate!).and_return(true)
        ItsiImporter.remove_existing_activity(@activity_with_offerings)
      end
    end
    describe "importing phase change / melting ice (fixture)" do
      it "should have a prediction section"
      it "the prediction section should predict the collect data sensor"
      it "should have a model in the further section"
    end
  end
end

describe ItsiImporter::ActivityImportRecord do
  
  describe "report method" do
    before(:each) do
      @diy_act = 21
      @record = ItsiImporter::ActivityImportRecord.new(@diy_act)
    end
    it "should include the exception message in report" do
      @record.fail(Exception.new("FAILURE!!!"))
      @record.report.should match /#{@diy_act}/
      @record.report.should match /FAILURE/
    end
  end
end



