APP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/settings.yml")[RAILS_ENV].symbolize_keys
APP_CONFIG[:use_gse] = true if APP_CONFIG[:use_gse] == nil