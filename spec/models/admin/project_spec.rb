require File.expand_path('../../../spec_helper', __FILE__)

describe Admin::Project do
  before(:each) do
    generate_jnlps_with_mocks
    @new_valid_project = Admin::Project.new(
      :active => true
    )
  end

  it "should create a new instance given valid attributes" do
    @new_valid_project.should be_valid
  end

  describe "a projects list of enabled vendor interfaces" do

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
      @all_interfaces.should have(@num_interfaces).things
    end

    it "should exist" do
      @new_valid_project.enabled_vendor_interfaces.should_not be_nil
    end

    it "should initially have all the existant vendor interfaces" do
      @new_valid_project.enabled_vendor_interfaces.should have(@num_interfaces).things
      @all_interfaces.each do |interface|
        @new_valid_project.enabled_vendor_interfaces.should include(interface)
      end
    end

    it "should allow removing vendor interfaces" do
      interface_to_remove = Probe::VendorInterface.find(:first)
      @new_valid_project.save # delete throws an exception if our model doesn't have an id
      @new_valid_project.enabled_vendor_interfaces.delete(interface_to_remove)
      @new_valid_project.enabled_vendor_interfaces.should have(@num_interfaces -1).things
      @new_valid_project.reload
      @new_valid_project.enabled_vendor_interfaces.should have(@num_interfaces -1).things
    end

    describe "custom_css" do
      before(:each) do
        @css =  ".testing {position:relative; padding:5px;}"
      end
      it "it should allow for custom css" do
        @new_valid_project.custom_css = @css
        @new_valid_project.should be_valid
        @new_valid_project.should be_using_custom_css
      end
      it "not be using custom css by default" do
        @new_valid_project.should_not be_using_custom_css
      end
    end


    describe "#available_bookmark_types" do
      subject  { @new_valid_project.available_bookmark_types }

      it "should return an array" do
        should be_kind_of Array
      end

      it "should include a generic bookmark type" do
        should include GenericBookmark.name
      end
    end

    describe "#enabled_bookmark_types" do
      subject  { @new_valid_project.enabled_bookmark_types }
      it "should return an array" do
        should be_kind_of Array
      end

      it "should be empty be default" do
        should be_empty
      end

    end

  end

  describe "class methods" do
    before(:each) do
      @clazz = Admin::Project
      APP_CONFIG[:test_value_true] = true
      APP_CONFIG[:test_value_false] = false
      APP_CONFIG[:test_value_nil] = nil
    end
    describe "reading configuration settings" do
      describe "settings_for" do
        it "should be a method" do
          @clazz.should respond_to :settings_for
        end
        it "should return true values" do
          @clazz.settings_for(:test_value_true).should be_true
        end
        it "should return false values" do
          @clazz.settings_for(:test_value_false).should be_false
        end
        it "should report nil values" do
          @clazz.should_receive(:notify_missing_setting)
          @clazz.settings_for(:test_value_nil).should be_nil
        end
        it "should report undefined values" do
          @clazz.should_receive(:notify_missing_setting)
          @clazz.settings_for(:something_undefined).should be_nil
        end
      end
    end
    describe "require_activity_descriptions" do
      it "should return the APP_CONFIG settings for :require_activity_descriptions" do
        @clazz.should_receive(:settings_for).with(:require_activity_descriptions).and_return(true)
        @clazz.require_activity_descriptions.should be_true
        @clazz.should_receive(:settings_for).with(:require_activity_descriptions).and_return(false)
        @clazz.require_activity_descriptions.should be_false
      end
    end
    describe "unique_activity_names" do
      it "should return the APP_CONFIG settings for :unique_activity_names" do
        @clazz.should_receive(:settings_for).with(:unique_activity_names).and_return(true)
        @clazz.unique_activity_names.should be_true
        @clazz.should_receive(:settings_for).with(:unique_activity_names).and_return(false)
        @clazz.unique_activity_names.should be_false
      end
    end
  end

end
