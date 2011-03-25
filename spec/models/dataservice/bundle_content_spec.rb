require 'spec_helper'

describe Dataservice::BundleContent do

  after(:each) do
     Delorean.back_to_the_present
  end
  before(:each) do
    Delorean.time_travel_to "1 month ago"
    @valid_attributes = {
      :id => 1,
      :bundle_logger_id => 1,
      :position => 1,
      :body => "value for body",
      :created_at => Time.now,
      :updated_at => Time.now,
      :otml => "value for otml",
      :processed => false,
      :valid_xml => false,
      :empty => false,
      :uuid => "value for uuid"
    }

    @valid_attributes_with_blob = {
      :bundle_logger_id => 1,
      :position => 2,
      :body => '<sessionBundles xmlns:xmi="http://www.omg.org/XMI" xmlns:sailuserdata="sailuserdata" start="2010-06-04T11:35:09.053-0400" stop="2010-06-04T11:44:53.604-0400" curnitUUID="cccccccc-0009-0000-0000-000000000000" sessionUUID="863174f4-79a1-4c44-9733-6a94be2963c9" lastModified="2010-06-04T11:44:10.136-0400" timeDifference="743" localIP="10.11.12.235">
          <sockParts podId="dddddddd-0002-0000-0000-000000000000" rimName="ot.learner.data" rimShape="[B">
            <sockEntries value="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" millisecondsOffset="541083"/>
          </sockParts>
          <agents role="RUN_WORKGROUP"/>
          <sdsReturnAddresses>http://has.staging.concord.org/dataservice/bundle_loggers/6/bundle_contents.bundle</sdsReturnAddresses>
          <launchProperties key="maven.jnlp.version" value="all-otrunk-snapshot-0.1.0-20100601.133611"/>
          <launchProperties key="sds_time" value="1275665709053"/>
          <launchProperties key="sailotrunk.otmlurl" value="http://has.staging.concord.org/investigations/7.dynamic_otml"/>
        </sessionBundles>'
    }
  end

  it "should create a new instance given valid attributes" do
    Dataservice::BundleContent.create!(@valid_attributes)
  end

  it "should extract blobs into separate model objects" do
    bundle_content = Dataservice::BundleContent.create!(@valid_attributes_with_blob)
    bundle_content.blobs.size.should eql(1)
    bundle_content.reload
    setup_expected(bundle_content.blobs.first)
    bundle_content.otml.should eql(@expected_otml)
    bundle_content.body.should eql(@expected_body)
    bundle_content.original_body.should eql(@valid_attributes_with_blob[:body])
  end

  # this has to be called after the blob extraction has happened, so we know what url to look for
  def setup_expected(blob)
    @blob_url = "http://localhost/dataservice/blobs/#{blob.id}.blob/#{blob.token}"
    @expected_otml =   '<?xml version="1.0" encoding="UTF-8"?>
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
          <OTStateRoot formatVersionString="1.0">
            <userMap>
              <entry key="c2f96d5e-6fee-11df-a23f-6dcecc6a5613">
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
                                <src>' + @blob_url + '</src>
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
              </entry>
            </userMap>
          </OTStateRoot>
        </objects>
      </otrunk>

      '
    @expected_body = '<sessionBundles xmlns:xmi="http://www.omg.org/XMI" xmlns:sailuserdata="sailuserdata" start="2010-06-04T11:35:09.053-0400" stop="2010-06-04T11:44:53.604-0400" curnitUUID="cccccccc-0009-0000-0000-000000000000" sessionUUID="863174f4-79a1-4c44-9733-6a94be2963c9" lastModified="2010-06-04T11:44:10.136-0400" timeDifference="743" localIP="10.11.12.235">
          <sockParts podId="dddddddd-0002-0000-0000-000000000000" rimName="ot.learner.data" rimShape="[B">
            <sockEntries value="' + Dataservice::BundleContent.b64gzip_pack(@expected_otml) + '" millisecondsOffset="541083"/>
          </sockParts>
          <agents role="RUN_WORKGROUP"/>
          <sdsReturnAddresses>http://has.staging.concord.org/dataservice/bundle_loggers/6/bundle_contents.bundle</sdsReturnAddresses>
          <launchProperties key="maven.jnlp.version" value="all-otrunk-snapshot-0.1.0-20100601.133611"/>
          <launchProperties key="sds_time" value="1275665709053"/>
          <launchProperties key="sailotrunk.otmlurl" value="http://has.staging.concord.org/investigations/7.dynamic_otml"/>
        </sessionBundles>'

    end

    describe "process_bunde" do
      before(:each) do
        @bundle = Dataservice::BundleContent.new()
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

      it "should not set valid_xml if the xml is valid" do
        # TODO: this probably should be better aproximation of the
        # actual sockentry protocols (which NP doesn't know very well)
        @bundle.body="<sessionBundles>FAKE IT.</sessionBundles>"
        @bundle.process_bundle
        @bundle.valid_xml.should be_true
      end

      it "should have an otml property if the xml is valid"  do
        # IMORTANT: this learner_otml is seriously FAKE. (np)
        @learner_otml = "<OTText>Hello World</OTText>"
        @ziped_otml = Dataservice::BundleContent.b64gzip_pack(@learner_otml)
        @learner_socks = "<ot.learner.data><sockEntries value=\"#{@ziped_otml}\"/></ot.learner.data>"
        @bundle.body="<sessionBundles>#{@learner_socks}</sessionBundles>"
        @bundle.process_bundle
        @bundle.otml.should_not be_empty
        puts "OTML IS #{@bundle.otml}"
      end

      it "should not have an otml property if the xml is invalid" do
        @bundle.body="<INVALIDXML>"
        @bundle.process_bundle
        @bundle.valid_xml.should be_false
        @bundle.otml.should be_empty
      end

    end
  
    describe "should run its callbacks" do
      before(:each) do
        @bundle = Dataservice::BundleContent.new(:body => "hi!")
      end

      it "should process the bundle before it creates bundlecontent" do
        @bundle.should_receive(:process_bundle)
        @bundle.run_callbacks(:before_create)
      end
      it "should process blobs after being created" do
        @bundle.should_receive(:process_blobs)
        @bundle.run_callbacks(:after_create)
      end
      it "should process bundles before save" do
        @bundle.should_receive(:process_bundle)
        @bundle.run_callbacks(:before_save)
      end
    end
end
