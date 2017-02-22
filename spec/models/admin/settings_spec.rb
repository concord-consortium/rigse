require File.expand_path('../../../spec_helper', __FILE__)

describe Admin::Settings do
  before(:each) do
    @new_valid_settings = Admin::Settings.new(
      :active => true
    )
  end

  it "should create a new instance given valid attributes" do
    expect(@new_valid_settings).to be_valid
  end


  describe "pub_interval" do
    describe "default value" do
      it "should be 5 minutes" do
        five_min = 300
        expect(@new_valid_settings.pub_interval).to eq(five_min)
      end
    end

    describe "less than minimum interval" do
      it "should fail validations" do
        @new_valid_settings.pub_interval = Admin::Settings::MinPubInterval - 1
        expect(@new_valid_settings).not_to be_valid
        puts @new_valid_settings.errors
      end
    end

  end
  describe "a list of enabled vendor interfaces" do

    before(:all) do
      # Currently all the probe configuration models including vendor_interfaces are loaded
      # into the test database from fixtures in config/probe_configurations by running:
      #
      #   rake db:test:prepare
      #
      # See: lib/tasks/db_test_prepare.rake
      #
      @all_interfaces = Probe::VendorInterface.find(:all)
      @num_interfaces = @all_interfaces.length
    end

    it "should have a sane testing environment" do
      expect(@all_interfaces.size).to eq(@num_interfaces)
    end

    it "should exist" do
      expect(@new_valid_settings.enabled_vendor_interfaces).not_to be_nil
    end

    it "should initially have all the existant vendor interfaces" do
      expect(@new_valid_settings.enabled_vendor_interfaces.size).to eq(@num_interfaces)
      @all_interfaces.each do |interface|
        expect(@new_valid_settings.enabled_vendor_interfaces).to include(interface)
      end
    end

    it "should allow removing vendor interfaces" do
      interface_to_remove = Probe::VendorInterface.find(:first)
      @new_valid_settings.save # delete throws an exception if our model doesn't have an id
      @new_valid_settings.enabled_vendor_interfaces.delete(interface_to_remove)
      expect(@new_valid_settings.enabled_vendor_interfaces.size).to eq(@num_interfaces -1)
      @new_valid_settings.reload
      expect(@new_valid_settings.enabled_vendor_interfaces.size).to eq(@num_interfaces -1)
    end

    describe "custom_css" do
      before(:each) do
        @css =  ".testing {position:relative; padding:5px;}"
      end
      it "it should allow for custom css" do
        @new_valid_settings.custom_css = @css
        expect(@new_valid_settings).to be_valid
        expect(@new_valid_settings).to be_using_custom_css
      end
      it "not be using custom css by default" do
        expect(@new_valid_settings).not_to be_using_custom_css
      end
    end


    describe "#available_bookmark_types" do
      subject  { @new_valid_settings.available_bookmark_types }

      it "should return an array" do
        is_expected.to be_kind_of Array
      end

      it "should include a generic bookmark type" do
        is_expected.to include Portal::GenericBookmark.name
      end
    end

    describe "#enabled_bookmark_types" do
      subject  { @new_valid_settings.enabled_bookmark_types }
      it "should return an array" do
        is_expected.to be_kind_of Array
      end

      it "should be empty be default" do
        is_expected.to be_empty
      end

    end

  end

  describe "class methods" do
    before(:each) do
      @clazz = Admin::Settings
      APP_CONFIG[:test_value_true] = true
      APP_CONFIG[:test_value_false] = false
      APP_CONFIG[:test_value_nil] = nil
    end
    describe "reading configuration settings" do
      describe "settings_for" do
        it "should be a method" do
          expect(@clazz).to respond_to :settings_for
        end
        it "should return true values" do
          expect(@clazz.settings_for(:test_value_true)).to be_truthy
        end
        it "should return false values" do
          expect(@clazz.settings_for(:test_value_false)).to be_falsey
        end
        it "should report nil values" do
          expect(@clazz).to receive(:notify_missing_setting)
          expect(@clazz.settings_for(:test_value_nil)).to be_nil
        end
        it "should report undefined values" do
          expect(@clazz).to receive(:notify_missing_setting)
          expect(@clazz.settings_for(:something_undefined)).to be_nil
        end
      end
    end
    describe "require_activity_descriptions" do
      it "should return the APP_CONFIG settings for :require_activity_descriptions" do
        expect(@clazz).to receive(:settings_for).with(:require_activity_descriptions).and_return(true)
        expect(@clazz.require_activity_descriptions).to be_truthy
        expect(@clazz).to receive(:settings_for).with(:require_activity_descriptions).and_return(false)
        expect(@clazz.require_activity_descriptions).to be_falsey
      end
    end
    describe "unique_activity_names" do
      it "should return the APP_CONFIG settings for :unique_activity_names" do
        expect(@clazz).to receive(:settings_for).with(:unique_activity_names).and_return(true)
        expect(@clazz.unique_activity_names).to be_truthy
        expect(@clazz).to receive(:settings_for).with(:unique_activity_names).and_return(false)
        expect(@clazz.unique_activity_names).to be_falsey
      end
    end

    describe "teachers_can_author" do
      let(:active_settings) { double() }
      it "should return true if the current settings allows teachers to author" do
        expect(@clazz).to receive(:default_settings).and_return(active_settings)
        expect(active_settings).to receive(:teachers_can_author).and_return(true)
        expect(@clazz.teachers_can_author?).to eq(true)
      end
      it "should return false if the current settings dissalows teachers authoring" do
        expect(@clazz).to receive(:default_settings).and_return(active_settings)
        expect(active_settings).to receive(:teachers_can_author).and_return(false)
        expect(@clazz.teachers_can_author?).to eq(false)
      end
    end
  end

end
