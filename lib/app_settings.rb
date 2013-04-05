require 'yaml'
require 'pathname'

module AppSettings

  APP_SETTINGS_PATH = File.expand_path("../../config/settings.yml", __FILE__)

  def settings_exists?(path=APP_SETTINGS_PATH)
    File.exists?(path) && File.stat(path).size > 0
  end

  def load_app_settings(env=::Rails.env)
    load_all_app_settings[env]
  end

  def load_all_app_settings(path=APP_SETTINGS_PATH)
    symbolize_app_settings(load_settings(path))
  end

  def symbolize_app_settings(settings)
    symbolized_settings = {}
    settings.each { |k,v| symbolized_settings[k] = v.recursive_symbolize_keys }
    symbolized_settings
  end

  def load_settings(path)
    begin
      YAML::load(ERB.new(IO.read(path)).result)
    rescue Errno::ENOENT
      {}
    end
  end

  def save_app_settings(new_app_settings, path=APP_SETTINGS_PATH)
    if File.exists?(path)
      path =  Pathname.new(path).realpath.to_s
    end
    new_settings = load_all_app_settings.merge(symbolize_app_settings(new_app_settings))
    save_settings(new_settings, path)
  end

  def save_settings(settings, path)
    File.open(path, 'w') { |f| f.write settings.to_yaml }
  end

end


# Recursively converts the keys in a Hash to symbols.
# Also converts the keys in any Array elements which are 
# Hashes to symbols.
module HashExtensions
  def recursive_symbolize_keys
    inject({}) do |acc, (k,v)|
      key = String === k ? k.to_sym : k
      case v
      when Hash
        value = v.recursive_symbolize_keys
      when Array
        value = v.inject([]) do |arr, e|
          arr << (e.is_a?(Hash) ? e.recursive_symbolize_keys : e)
        end
      else
        value = v
      end
      acc[key] = value
      acc
    end
  end
end
Hash.send(:include, HashExtensions)
