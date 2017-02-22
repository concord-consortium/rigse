require 'spec_helper'

describe JnlpHelper do
  subject { Object.new().extend(JnlpHelper) }

  describe "pub_interval" do
    describe "uses seconds in settings" do
      it "should be 30000 when the settings say 30" do
        allow(Admin::Settings).to receive(:pub_interval).and_return(30)
        expect(subject.pub_interval).to eq(30000)
      end
      it "should be 10000 when the settings say 10" do
        allow(Admin::Settings).to receive(:pub_interval).and_return(10)
        expect(subject.pub_interval).to eq(10000)
      end
    end
  end

  describe "system_properties" do
    describe "with pub enabled, and a learner" do
      before :each do
        @settings = Admin::Settings.new(:pub_interval => 10,
          :use_periodic_bundle_uploading => true)
        @student = double()
        @user = Factory(:user)
        @student.stub(:user => @user)
        pbl   = double()
        @learner = double(:student => @student, :periodic_bundle_logger => pbl)
      end
      it "should include the update interval as a property" do
        subject.stub(:current_settings => @settings)
        subject.stub(:current_visitor => @user)
        allow(subject).to receive(:dataservice_periodic_bundle_logger_periodic_bundle_contents_url).and_return("URL")
        allow(subject).to receive(:dataservice_periodic_bundle_logger_session_end_notification_url).and_return("URL")
        props = subject.system_properties(:learner => @learner)
        found = props.detect do |pair|
          key,value = pair
          key == "otrunk.periodic.uploading.interval"
          value = subject.pub_interval
        end
        expect(found).not_to be_empty
      end
    end
  end
end
