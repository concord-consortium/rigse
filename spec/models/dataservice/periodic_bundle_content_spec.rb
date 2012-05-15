require File.expand_path('../../../spec_helper', __FILE__)

describe Dataservice::PeriodicBundleContent do

  after(:each) do
     # Delorean.back_to_the_present
  end
  before(:each) do
    # Delorean.time_travel_to "1 month ago"
    @valid_attributes = {
      :id => 1,
      :periodic_bundle_logger_id => 1,
      :body => "value for body",
      :created_at => Time.now,
      :updated_at => Time.now,
      :processed => false,
      :valid_xml => false,
      :empty => false,
      :uuid => "value for uuid"
    }

    setup_expected("gzb64:" + B64Gzip.pack("some fake blob data"))
    @valid_attributes_with_blob = {
      :periodic_bundle_logger_id => 1,
      :body => @expected_body
    }
    # disable the after_save there is observer_spec to test that specific call
    # we might want to try out the no_peeping_toms gem to handle this 
    # https://github.com/patmaddox/no-peeping-toms
    Dataservice::PeriodicBundleContentObserver.instance.should_receive(:after_save).any_number_of_times
    Dataservice::PeriodicBundleContentObserver.instance.should_receive(:after_create).any_number_of_times
  end

  it "should create a new instance given valid attributes" do
    Dataservice::PeriodicBundleContent.create!(@valid_attributes)
  end

  it "should extract blobs into separate model objects" do
    bundle_content = Dataservice::PeriodicBundleContent.create!(@valid_attributes_with_blob)
    bundle_content.blobs.size.should eql(1)
    bundle_content.reload
    setup_expected(bundle_content.blobs.first)
    bundle_content.body.should eql(@expected_body)
  end

  it "after multiple-processing passes, the blob count should be constant" do
    bundle_content = Dataservice::PeriodicBundleContent.create!(@valid_attributes_with_blob)
    bundle_content.blobs.size.should eql(1)
    bundle_content.extract_parts
    bundle_content.processed=false
    bundle_content.extract_parts
    bundle_content.process_bundle
    bundle_content.processed=false
    bundle_content.process_bundle
    bundle_content.save
    bundle_content.blobs.size.should eql(1)
  end

  it "when a body with no learner data is added, the bundle count doesn't change" do
    # not a sock-entry body
    bundle_content = Dataservice::PeriodicBundleContent.create!(@valid_attributes_with_blob)
    bundle_content.body="<gah>BAD BAD</gah>"
    bundle_content.save!
    bundle_content.reload
    bundle_content.blobs.size.should eql(1)
  end

  # TODO, not supported really, but we should expect more blobs if
  # we updated the body with new learner data (?)

  # this has to be called after the blob extraction has happened, so we know what url to look for
  def setup_expected(blob)
    blob_content = blob.is_a?(Dataservice::Blob) ? "http://#{URI.parse(APP_CONFIG[:site_url]).host}/dataservice/blobs/#{blob.id}.blob/#{blob.token}" : blob
    @expected_body =   '<?xml version="1.0" encoding="UTF-8"?>
      <otrunk id="04dc61c3-6ff0-11df-a23f-6dcecc6a5613">
        <imports>
          <import class="org.concord.otrunk.OTStateRoot" />
          <import class="org.concord.otrunk.user.OTUserObject" />
          <import class="org.concord.otrunk.user.OTReferenceMap" />
          <import class="org.concord.otrunk.ui.OTCardContainer" />
          <import class="org.concord.otrunk.ui.OTSection" />
          <import class="org.concord.otrunk.ui.OTChoice" />
          <import class="org.concord.otrunk.ui.OTText" />
          <import class="org.concord.datagraph.state.OTDataGraphable" />
          <import class="org.concord.data.state.OTDataStore" />
          <import class="org.concord.otrunk.util.OTLabbookBundle" />
          <import class="org.concord.otrunk.util.OTLabbookEntry" />
          <import class="org.concord.datagraph.state.OTDataCollector" />
          <import class="org.concord.datagraph.state.OTDataAxis" />
          <import class="org.concord.otrunk.view.OTFolderObject" />
          <import class="org.concord.framework.otrunk.wrapper.OTBlob" />
          <import class="org.concord.graph.util.state.OTDrawingTool" />
          <import class="org.concord.otrunk.labbook.OTLabbookButton" />
          <import class="org.concord.otrunk.labbook.OTLabbookEntryChooser" />
        </imports>
        <objects>
          <OTReferenceMap>
            <user>
              <OTUserObject id="c2f96d5e-6fee-11df-a23f-6dcecc6a5613" />
            </user>
            <map>
              <entry key="fe6dcc58-6f7d-11df-81fc-001ec94098a1!/lab_book_bundle">
                <OTLabbookBundle>
                  <entries>
                    <OTLabbookEntry timeStamp="June 4 at 11:39" type="Graphs" note="Add a note describing this entry...">
                      <oTObject>
                        <OTDataCollector id="540d78fe-6fef-11df-a23f-6dcecc6a5613" useDefaultToolBar="false" showControlBar="true" title="Government Support for Educational Technology" displayButtons="4" name="Government Support for Educational Technology" multipleGraphableEnabled="false" autoScaleEnabled="false">
                          <source>
                            <OTDataGraphable drawMarks="true" connectPoints="true" visible="true" color="16711680" showAllChannels="false" name="Governmen..." xColumn="0" lineWidth="2.0" yColumn="1" controllable="false">
                              <dataStore>
                                <OTDataStore numberChannels="2" />
                              </dataStore>
                            </OTDataGraphable>
                          </source>
                          <xDataAxis>
                            <OTDataAxis min="1981.708" max="2020.0248" label="Time" labelFormat="None" units="years">
                              <customGridLabels />
                            </OTDataAxis>
                          </xDataAxis>
                          <dataSetFolder>
                            <OTFolderObject />
                          </dataSetFolder>
                          <yDataAxis>
                            <OTDataAxis min="19.401735" max="82.00013" label="Temperature" labelFormat="None" units="C">
                              <customGridLabels />
                            </OTDataAxis>
                          </yDataAxis>
                        </OTDataCollector>
                      </oTObject>
                      <container>
                        <object refid="fe6dcc58-6f7d-11df-81fc-001ec94098a1!/section_card_container_activity_17/cards[0]" />
                      </container>
                      <originalObject>
                        <object refid="fe6dcc58-6f7d-11df-81fc-001ec94098a1!/data_collector_3" />
                      </originalObject>
                    </OTLabbookEntry>
                    <OTLabbookEntry timeStamp="June 4 at 11:41" type="Snapshots" note="Add a note describing this entry...">
                      <oTObject>
                        <OTBlob id="aae0cc59-6fef-11df-a23f-6dcecc6a5613">
                          <src>' + blob_content + '</src>
                        </OTBlob>
                      </oTObject>
                      <container>
                        <object refid="fe6dcc58-6f7d-11df-81fc-001ec94098a1!/section_card_container_activity_17/cards[0]" />
                      </container>
                      <originalObject>
                        <object refid="fe6dcc58-6f7d-11df-81fc-001ec94098a1!/mw_modeler_page_2" />
                      </originalObject>
                      <drawingTool>
                        <OTDrawingTool id="aae0cc5b-6fef-11df-a23f-6dcecc6a5613" scaleBackground="true">
                          <backgroundSrc>
                            <object refid="aae0cc59-6fef-11df-a23f-6dcecc6a5613" />
                          </backgroundSrc>
                        </OTDrawingTool>
                      </drawingTool>
                    </OTLabbookEntry>
                  </entries>
                </OTLabbookBundle>
              </entry>
            </map>
          </OTReferenceMap>
        </objects>
      </otrunk>

      '
    end

    describe "process_bunde" do
      before(:each) do
        @bundle = Dataservice::PeriodicBundleContent.new()
      end

      it "should set processed to true" do
        @bundle.body = ""
        @bundle.processed.should be_false
        #@bundle.should_receive(:processed).with(true)
        @bundle.process_bundle
        @bundle.processed.should be_true
      end

      it "should set empty to true with a blank body" do
        @bundle.body = ""
        @bundle.process_bundle
        @bundle.empty.should be_true
      end

      it "should set empty to true with a nil body" do
        @bundle.body = nil
        @bundle.process_bundle
        @bundle.empty.should be_true
      end

      it "should not set empt? if there is a body" do
        @bundle.body = "testing"
        @bundle.process_bundle
        @bundle.empty.should be_false
      end

      it "should not set valid_xml if the xml is invalid" do
        @bundle.body = "testing"
        @bundle.process_bundle
        @bundle.valid_xml.should be_false
      end

      it "should set valid_xml if the xml is valid" do
        # TODO: this probably should be better aproximation of the
        # actual sockentry protocols (which NP doesn't know very well)
        @bundle.body="<sessionBundles>FAKE IT.</sessionBundles>"
        @bundle.process_bundle
        @bundle.valid_xml.should be_true
      end
    end

    describe "should run its callbacks" do
      before(:each) do
        @bundle = Dataservice::BundleContent.new(:body => "hi!")
      end

      it "should process bundles before save" do
        @bundle.should_receive(:process_bundle)
        # this runs the save callbacks and the return value of false causes it to skip the after_save callbacks
        @bundle.run_callbacks(:save) { false }
      end

      it "should call process blobs after processing bundle" do
        @bundle.should_receive(:process_blobs)
        @bundle.process_bundle
      end
    end

    describe "collaborations and collaborators" do
      before(:each) do
        @bundle = Factory(:dataservice_bundle_content)
        @student_a = Factory(:portal_student)
        @student_b = Factory(:portal_student)
        @student_c = Factory(:portal_student)
      end
      describe "basic associations" do
        xit "should allow for collaborators" do
          @bundle.collaborators << @student_a
          @bundle.collaborators << @student_b
          @bundle.collaborators << @student_c
          @bundle.save
          @bundle.reload
          @bundle.should have(3).collaborators
          @bundle.collaborators.each do |s|
            s.collaborative_bundles.should_not be_nil
            s.collaborative_bundles.should include @bundle
          end
        end
      end

      describe "copying data" do
        before(:each) do
          @main_student = Factory(:portal_student)
          @clazz = mock_model(Portal::Clazz)
          @offering = mock_model(Portal::Offering, :clazz => @clazz)
          @learner = mock_model(Portal::Learner, 
                                :portal_student => @main_student, 
                                :offering =>@offering)
          @learner_a = mock_model(Portal::Learner)
          @contents_a = []
          @bundle_logger = mock_model(Dataservice::BundleLogger, {
            :learner => @learner,
            :bundle_contents => @contents_a
          })
          @bundle.bundle_logger = @bundle_logger
        end
        xit "should copy the bundle contents" do
          @bundle.collaborators << @student_a
          @offering.should_receive(:find_or_create_learner).with(@student_a).and_return(@learner_a)
          @learner_a.should_receive(:bundle_logger).and_return(@bundle_logger)
          @bundle.copy_to_collaborators
          @contents_a.should have(1).bundle_content
        end
      end
    end
end
