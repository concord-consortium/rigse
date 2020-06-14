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
      end
    end

  end
  describe "bookmarks" do

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



  # TODO: auto-generated
  describe '#init' do
    it 'init' do
      settings = described_class.new
      result = settings.init

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#name' do
    it 'name' do
      settings = described_class.new
      result = settings.name

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#update_attributes' do
    xit 'update_attributes' do
      settings = described_class.new
      hashy = double('hashy')
      result = settings.update_attributes(hashy)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#display_type' do
    it 'display_type' do
      settings = described_class.new
      result = settings.display_type

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.searchable_attributes' do
    it 'searchable_attributes' do
      result = described_class.searchable_attributes

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.default_settings' do
    it 'default_settings' do
      result = described_class.default_settings

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '.summary_info' do
    it 'summary_info' do
      result = described_class.summary_info

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.pub_interval' do
    it 'pub_interval' do
      result = described_class.pub_interval

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.notify_missing_setting' do
    it 'notify_missing_setting' do
      symbol = double('symbol')
      result = described_class.notify_missing_setting(symbol)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '.settings_for' do
    it 'settings_for' do
      symbol = double('symbol')
      result = described_class.settings_for(symbol)

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '.require_activity_descriptions' do
    it 'require_activity_descriptions' do
      result = described_class.require_activity_descriptions

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '.unique_activity_names' do
    it 'unique_activity_names' do
      result = described_class.unique_activity_names

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '.teachers_can_author?' do
    it 'teachers_can_author?' do
      result = described_class.teachers_can_author?

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#default_settings?' do
    it 'default_settings?' do
      settings = described_class.new
      result = settings.default_settings?

      expect(result).to be_nil
    end
  end

  # TODO: auto-generated
  describe '#summary_info' do
    it 'summary_info' do
      settings = described_class.new
      result = settings.summary_info

      expect(result).to match(/There are 0 Teachers without Users
There are 0 Students which no longer have Teachers
There are 0 Classes which no longer have Teachers
There are 0 Learners which are no longer associated with Students/)
    end
  end

  # TODO: auto-generated
  describe '#available_bookmark_types' do
    it 'available_bookmark_types' do
      settings = described_class.new
      result = settings.available_bookmark_types

      expect(result).not_to be_nil
    end
  end


end
