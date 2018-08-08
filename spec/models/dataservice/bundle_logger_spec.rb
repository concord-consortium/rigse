require File.expand_path('../../../spec_helper', __FILE__)

describe Dataservice::BundleLogger do
  context "without after_save" do
    before(:each) do
      # disable the after_save there is observer_spec to test that specific call
      # and there is a spec to test extraction of saveables
      # we might want to try out the no_peeping_toms gem to handle this 
      # https://github.com/patmaddox/no-peeping-toms
      # disabling this also allows us to make invalid bundles for testing
      # also if it is enabled then the factory :full_dataservice_bundle_content needs to be used
      # and finally if the :full_dataservice_bundle_content is used then the bundle_content will have
      # a predefined bundle_logger which then breaks the '<<' assigments below
      allow(Dataservice::BundleContentObserver.instance).to receive(:after_save)

      @valid_attributes = {
      
      }
    end

    it "should create a new instance given valid attributes" do
      Dataservice::BundleLogger.create!(@valid_attributes)
    end

    describe "last_non_empty_bundle_content finder sql" do
      before(:each) do

        @bundle_logger = Dataservice::BundleLogger.create(@valid_attributes)
        @good_bundle_content_1 = Factory(:dataservice_bundle_content)
        @good_bundle_content_2 = Factory(:dataservice_bundle_content)
        @good_bundle_content_3 = Factory(:dataservice_bundle_content)

        # these won't succeed with synchronous bundle processing
        @bad_null_body_content = Dataservice::BundleContent.create()
        @bad_invalid_xml_content = Factory(:dataservice_bundle_content, :body=>"goo")
      end
      it "should find nothing with no associated content" do
        expect(@bundle_logger.last_non_empty_bundle_content).to be_nil
      end
      it "should find nothing with a null body content" do
        @bundle_logger.bundle_contents << @bad_null_body_content
        expect(@bundle_logger.last_non_empty_bundle_content).to be_nil
      end
      it "should find nothing with invalid xml content" do
        @bundle_logger.bundle_contents << @bad_invalid_xml_content
        expect(@bundle_logger.last_non_empty_bundle_content).to be_nil
      end
      it "should find the first and only content if there is only one valid bundle_conent" do
        @bundle_logger.bundle_contents << @good_bundle_content_1
        expect(@bundle_logger.last_non_empty_bundle_content).to eq(@good_bundle_content_1)
      end
      it "should find the third content if there are 3 valid bundle_conents" do
        @bundle_logger.bundle_contents << @good_bundle_content_1
        @bundle_logger.bundle_contents << @good_bundle_content_2
        @bundle_logger.bundle_contents << @good_bundle_content_3
        expect(@bundle_logger.last_non_empty_bundle_content).to eq(@good_bundle_content_3)
      end

    end

    describe "last non empty bundle" do
      before(:each) do
        @first    = Factory(:dataservice_bundle_content)
        @second   = Factory(:dataservice_bundle_content)
        @third    = Factory(:dataservice_bundle_content)
        @badxml   = Factory(:dataservice_bundle_content, :body => "badness (non xml)")
        @nullbody = Factory(:dataservice_bundle_content, :body => nil)
        @emptybody= Factory(:dataservice_bundle_content, :body => "")
        @no_data  = Factory(:dataservice_bundle_content, :body => SailBundleContent::EMPTY_BUNDLE)
        @logger = Dataservice::BundleLogger.create
      end

      it "should find nothing with only invalid bundles" do
        @logger.bundle_contents << @nullbody
        @logger.bundle_contents << @emptybody
        @logger.bundle_contents << @badxml
        @logger.bundle_contents << @no_data
        @logger.save
        @logger.reload
        expect(@logger.bundle_contents.size).to eq(4)
        expect(@logger.last_non_empty_bundle_content).to be_nil
      end

      it "should find the third of three good bundles" do
        @logger.bundle_contents << @first
        @logger.bundle_contents << @second
        @logger.bundle_contents << @third
        @logger.save
        @logger.reload
        expect(@logger.bundle_contents.size).to eq(3)
        expect(@logger.last_non_empty_bundle_content).to eq(@third)
      end
    
      it "should find @second when the third data is bad" do
        @logger.bundle_contents << @first
        @logger.bundle_contents << @second
        @logger.bundle_contents << @no_data
        @logger.save
        @logger.reload
        expect(@logger.bundle_contents.size).to eq(3)
        expect(@logger.last_non_empty_bundle_content).to eq(@second)
      end

      it "should find the @second when the first data is bad too" do
        @logger.bundle_contents << @nullbody
        @logger.bundle_contents << @second
        @logger.bundle_contents << @no_data
        @logger.save
        @logger.reload
        expect(@logger.bundle_contents.size).to eq(3)
        expect(@logger.last_non_empty_bundle_content).to eq(@second)

      end

    end
  end
  
  context "with after_save" do
    # this should be run with the after_save turned on because this is how 
    # the actual code will work: empty bundles will be created
    # if after_save is disabled here then it will hide errors that happen when 
    # empty bundles are created
    
    describe "in process bundles" do
      before(:each) do
        @bundle_logger = Dataservice::BundleLogger.create(@valid_attributes)
      end
    
      it "should start out with no in_progress_bundle" do
        expect(@bundle_logger.in_progress_bundle).to be_nil
      end

      describe "start bundle" do
        it "should assign a new in_progress bundle if there is none" do
          @bundle_logger.start_bundle
          expect(@bundle_logger.in_progress_bundle).not_to be_nil
          expect(@bundle_logger.in_progress_bundle_id).not_to be_nil
        end
      
        it "should create the bundle as the most recent bundle" do
          @bundle_logger.bundle_contents << Dataservice::BundleContent.create
          @bundle_logger.bundle_contents << Dataservice::BundleContent.create
          @bundle_logger.bundle_contents << Dataservice::BundleContent.create
          @bundle_logger.start_bundle
          expect(@bundle_logger.bundle_contents.size).to eq(4)
          expect(@bundle_logger.in_progress_bundle).to eq(@bundle_logger.bundle_contents.last)
        end

        it "should create new bundle which is empty and not the last-non-empty bundle" do
          @bundle_logger.start_bundle
          expect(@bundle_logger.last_non_empty_bundle_content).not_to eq(@bundle_logger.in_progress_bundle)
        end

        it "should reuse an existing in_progress bundle if there is one" do
          @new_bundle = Dataservice::BundleContent.create({:bundle_logger => @bundle_logger})
          @bundle_logger.in_progress_bundle = @new_bundle
          @bundle_logger.save
          @bundle_logger.reload
          expect(@bundle_logger.in_progress_bundle).to eq(@new_bundle)
          @bundle_logger.bundle_contents.last == @new_bundle
        end

        it "should have one more bundle after starting a new one" do
          old_size = @bundle_logger.bundle_contents.size
          @bundle_logger.start_bundle
          new_size = @bundle_logger.bundle_contents.size
          expect(new_size).to eq(old_size + 1)
        end
      end

      describe "end bundle" do
        before(:each) do
          @bundle_logger.start_bundle
        end
        it "should save! the pending bundle when it ends" do
          expect(@bundle_logger.in_progress_bundle).to receive(:save!)
          @bundle_logger.end_bundle
        end
        it "should not have any new pending bundles after end" do
          @bundle_logger.end_bundle
          expect(@bundle_logger.in_progress_bundle).to be_nil
          @bundle_logger.reload
          expect(@bundle_logger.in_progress_bundle).to be_nil
        end
      end
    end
  end
end
