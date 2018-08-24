require File.expand_path('../../spec_helper', __FILE__)

class ClassWithAppSettings
   include AppSettings
end

describe "A class with the AppSettings module included" do
  
  before(:each) do
    @class_with_app_settings = ClassWithAppSettings.new
    @settings_with_symbol_keys_path = "#{::Rails.root.to_s}/spec/fixtures/settings_with_symbol_keys.yml"
    @settings_with_string_keys_path = "#{::Rails.root.to_s}/spec/fixtures/settings_with_string_keys.yml"
    @settings_with_mixed_keys_path = "#{::Rails.root.to_s}/spec/fixtures/settings_with_mixed_keys.yml"
  end
  
  describe "ClassWithAppSettings#load_and_symbolize_settings" do
    
    it "should set return a recursively symbolized hash when given a path to a YAML settings file with symbolized keys" do
      @class_with_app_settings.load_all_app_settings(@settings_with_symbol_keys_path)
    end

    it "should set return a recursively symbolized hash when given a path to a YAML settings file with string keys" do
      @class_with_app_settings.load_all_app_settings(@settings_with_string_keys_path)
    end

    it "should set return a recursively symbolized hash when given a path to a YAML settings file with mixed keys" do
      @class_with_app_settings.load_all_app_settings(@settings_with_mixed_keys_path)
    end

  end
  

  # TODO: auto-generated
  describe '#settings_exists?' do
    it 'settings_exists?' do
      app_settings = ClassWithAppSettings.new
      path = double('path')
      result = app_settings.settings_exists?('path')

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#load_app_settings' do
    it 'load_app_settings' do
      app_settings = ClassWithAppSettings.new
      env = double('env')
      result = app_settings.load_app_settings(env)

      expect(result).to be_nil
    end
  end


  # TODO: auto-generated
  describe '#symbolize_app_settings' do
    it 'symbolize_app_settings' do
      app_settings = ClassWithAppSettings.new
      settings = {}
      result = app_settings.symbolize_app_settings(settings)

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#load_settings' do
    it 'load_settings' do
      app_settings = ClassWithAppSettings.new
      path = double('path')
      result = app_settings.load_settings('path')

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#save_app_settings' do
    it 'save_app_settings' do
      app_settings = ClassWithAppSettings.new
      new_app_settings = {}
      path = double('path')
      result = app_settings.save_app_settings(new_app_settings, 'path')

      expect(result).not_to be_nil
    end
  end

  # TODO: auto-generated
  describe '#save_settings' do
    it 'save_settings' do
      app_settings = ClassWithAppSettings.new
      result = app_settings.save_settings({}, 'path')

      expect(result).not_to be_nil
    end
  end


end
