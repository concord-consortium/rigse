APP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/settings.yml")[RAILS_ENV].recursive_symbolize_keys

APP_CONFIG[:use_gse] = true if APP_CONFIG[:use_gse] == nil

USING_RITES = APP_CONFIG[:theme] && (APP_CONFIG[:theme] == 'default' || APP_CONFIG[:theme] == 'rites')
NOT_USING_RITES = !USING_RITES

NOT_USING_JNLPS = APP_CONFIG[:runnables_use] && APP_CONFIG[:runnables_use] == 'browser'
USING_JNLPS = !NOT_USING_JNLPS

USING_HOPTOAD = APP_CONFIG[:exception_notifier] && APP_CONFIG[:exception_notifier] == 'hoptoad' && APP_CONFIG[:hoptoad_api_key]
NOT_USING_HOPTOAD = !USING_HOPTOAD