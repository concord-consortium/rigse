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
      settings_hash = @class_with_app_settings.load_all_app_settings(@settings_with_symbol_keys_path)
    end

    it "should set return a recursively symbolized hash when given a path to a YAML settings file with string keys" do
      settings_hash = @class_with_app_settings.load_all_app_settings(@settings_with_string_keys_path)
    end

    it "should set return a recursively symbolized hash when given a path to a YAML settings file with mixed keys" do
      settings_hash = @class_with_app_settings.load_all_app_settings(@settings_with_mixed_keys_path)
    end

  end
  
end
