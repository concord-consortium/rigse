require 'spec_helper'

describe JnlpHelper, type: :helper  do
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
        allow(@student).to receive_messages(:user => @user)
        pbl   = double()
        @learner = double(:student => @student, :periodic_bundle_logger => pbl)
      end
      it "should include the update interval as a property" do
        allow(subject).to receive_messages(:current_settings => @settings)
        allow(subject).to receive_messages(:current_visitor => @user)
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

  # TODO: auto-generated
  describe '#jnlp_icon_url' do
    it 'works' do
      result = helper.jnlp_icon_url

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#jnlp_splash_url' do
    xit 'works' do
      result = helper.jnlp_splash_url(FactoryGirl.create(:portal_learner))

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#pub_interval' do
    it 'works' do
      result = helper.pub_interval

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#system_properties' do
    xit 'works' do
      result = helper.system_properties({})

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#jnlp_headers' do
    xit 'works' do
      result = helper.jnlp_headers(runnable)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#jnlp_information' do
    xit 'works' do
      result = helper.jnlp_information('<root/>', FactoryGirl.create(:full_portal_learner))

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#jnlp_installer_vendor' do
    it 'works' do
      result = helper.jnlp_installer_vendor

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#load_yaml' do
    xit 'works' do
      result = helper.load_yaml('filename')

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#jnlp_installer_project' do
    it 'works' do
      result = helper.jnlp_installer_project

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#jnlp_installer_version' do
    it 'works' do
      result = helper.jnlp_installer_version

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#jnlp_installer_old_versions' do
    it 'works' do
      result = helper.jnlp_installer_old_versions

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#jnlp_mac_java_config' do
    xit 'works' do
      result = helper.jnlp_mac_java_config('<root/>')

      expect(result).not_to be_nil
    end
  end


end
