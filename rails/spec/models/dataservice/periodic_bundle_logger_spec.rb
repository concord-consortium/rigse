require File.expand_path('../../../spec_helper', __FILE__)

describe Dataservice::PeriodicBundleLogger do
  it "should create a new logger" do
  	pb_logger = Dataservice::PeriodicBundleLogger.create
  end

  describe "#sail_bundle" do
  	let(:fake_bundle_contents) {
      '<?xml version="1.0" encoding="UTF-8"?>
      <otrunk id="04dc61c3-6ff0-11df-a23f-6dcecc6a5613">
        <imports>
          <import class="org.concord.otrunk.OTStateRoot" />
          <import class="org.concord.otrunk.user.OTUserObject" />
          <import class="org.concord.otrunk.user.OTReferenceMap" />
        </imports>
        <objects>
          <OTReferenceMap>
            <user>
              <OTUserObject id="c2f96d5e-6fee-11df-a23f-6dcecc6a5613" />
            </user>
            <map>
              <entry key="fe6dcc58-6f7d-11df-81fc-001ec94098a1!/nested_objects_with_ids">
                <OTBasicObject>
                  <child>
                    <OTBasicObject name="First" id="onetwothree">
                      <child>
                        <OTBasicObject name="Second" id="fourfivesix" />
                      </child>
                    </OTBasicObject>
                  </child>
                </OTBasicObject>
              </entry>
            </map>
          </OTReferenceMap>
        </objects>
      </otrunk>

      '
  	}

  	it "should extract the parts from bundles that haven't been extracted yet" do
      pb_logger = Dataservice::PeriodicBundleLogger.create

      # disable the observer so the parts of this bundle don't get extracted
      allow(Dataservice::PeriodicBundleContentObserver.instance).to receive(:after_create)

      # note this is invalid otml so if you want to use this for something real you need to at 
      # least add an import for OTBasicObject
      pb_bundle_contents = pb_logger.periodic_bundle_contents.create(:body => fake_bundle_contents )
      allow(pb_logger).to receive_message_chain(:learner, :bundle_logger, :last_non_empty_bundle_content).and_return(nil)
      allow(pb_logger).to receive_message_chain(:learner, :uuid).and_return(UUIDTools::UUID.timestamp_create)
      allow(pb_logger).to receive(:imports).and_return([])
      expect(pb_bundle_contents.parts_extracted).to eq(false)
      expect(pb_logger.periodic_bundle_parts.size).to eq(0)
      pb_logger.sail_bundle
      pb_bundle_contents.reload
      expect(pb_bundle_contents.parts_extracted).to eq(true)
      expect(pb_logger.periodic_bundle_parts.size).to be > 0
  	end

  	it "should extract parts the last non pub bundle if there is one" do
      pb_logger = Dataservice::PeriodicBundleLogger.create

      # disable the observer so the parts of this bundle don't get extracted
      allow(Dataservice::PeriodicBundleContentObserver.instance).to receive(:after_create)

      non_pub_bundle_contents = double()
      allow(pb_logger).to receive_message_chain(:learner, :bundle_logger, :last_non_empty_bundle_content).and_return(non_pub_bundle_contents)

      # note this is invalid otml so if you want to use this for something real you need to at 
      # least add an import for OTBasicObject
      expect(non_pub_bundle_contents).to receive(:otml).and_return(fake_bundle_contents)

      allow(pb_logger).to receive_message_chain(:learner, :uuid).and_return(UUIDTools::UUID.timestamp_create)
      allow(pb_logger).to receive(:imports).and_return([])
      expect(pb_logger.periodic_bundle_parts.size).to eq(0)
      pb_logger.sail_bundle
      expect(pb_logger.periodic_bundle_parts.size).to be > 0
    end
  end


  # TODO: auto-generated
  describe '#sail_bundle' do
    xit 'sail_bundle' do
      periodic_bundle_logger = described_class.new
      result = periodic_bundle_logger.sail_bundle

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#otml' do
    xit 'otml' do
      periodic_bundle_logger = described_class.new
      result = periodic_bundle_logger.otml

      expect(result).not_to be_nil
    end
  end


end
