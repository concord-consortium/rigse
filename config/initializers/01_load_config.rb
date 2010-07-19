include AppSettings
APP_CONFIG = AppSettings.load_app_settings

APP_CONFIG[:use_gse] = true if APP_CONFIG[:use_gse] == nil

USING_RITES = APP_CONFIG[:theme] && (APP_CONFIG[:theme] == 'default' || APP_CONFIG[:theme] == 'rites')
NOT_USING_RITES = !USING_RITES

NOT_USING_JNLPS = APP_CONFIG[:runnables_use] && APP_CONFIG[:runnables_use] != 'otrunk_jnlp'
USING_JNLPS = !NOT_USING_JNLPS
