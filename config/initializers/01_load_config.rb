include AppSettings
APP_CONFIG = AppSettings.load_app_settings

# set the defaults
APP_CONFIG = {
  :use_gse => true,
  :recent_activity_on_login => true,
  :top_level_container_name => 'investigation'
}.merge(APP_CONFIG)

USING_RITES = APP_CONFIG[:theme] && (APP_CONFIG[:theme] == 'default' || APP_CONFIG[:theme] == 'rites')
NOT_USING_RITES = !USING_RITES

NOT_USING_JNLPS = APP_CONFIG[:runnables_use] && APP_CONFIG[:runnables_use] != 'otrunk_jnlp'
USING_JNLPS = !NOT_USING_JNLPS

TOP_LEVEL_CONTAINER_NAME = APP_CONFIG[:top_level_container_name]

TOP_LEVEL_CONTAINER_SYM         = TOP_LEVEL_CONTAINER_NAME.to_sym

TOP_LEVEL_CONTAINER_NAME_PLURAL = TOP_LEVEL_CONTAINER_NAME.pluralize

TOP_LEVEL_CONTAINER_SYM_PLURAL  = TOP_LEVEL_CONTAINER_NAME_PLURAL.to_sym
