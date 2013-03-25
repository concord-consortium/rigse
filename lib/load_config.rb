require File.expand_path('../app_settings', __FILE__)
include AppSettings
APP_CONFIG = AppSettings.load_app_settings

# set the defaults
APP_CONFIG = {
  :use_gse => true,
  :recent_activity_on_login => true,
  :top_level_container_name => 'investigation',
  :use_jnlps => true,
  :host => nil
}.merge(APP_CONFIG)

APP_CONFIG[:host] = APP_CONFIG[:site_url].gsub("http://","")

USING_RITES = APP_CONFIG[:theme] && (APP_CONFIG[:theme] == 'default' || APP_CONFIG[:theme] == 'rites')
NOT_USING_RITES = !USING_RITES

# handle legacy configuration
if APP_CONFIG[:runnables_use] && APP_CONFIG[:runnables_use] != 'otrunk_jnlp'
  APP_CONFIG[:use_jnlps] = false
end

TOP_LEVEL_CONTAINER_NAME = APP_CONFIG[:top_level_container_name]

TOP_LEVEL_CONTAINER_SYM         = TOP_LEVEL_CONTAINER_NAME.to_sym

TOP_LEVEL_CONTAINER_NAME_PLURAL = TOP_LEVEL_CONTAINER_NAME.pluralize

TOP_LEVEL_CONTAINER_SYM_PLURAL  = TOP_LEVEL_CONTAINER_NAME_PLURAL.to_sym
