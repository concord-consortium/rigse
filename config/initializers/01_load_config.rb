include AppSettings
APP_CONFIG = AppSettings.load_app_settings

APP_CONFIG[:use_gse] = true if APP_CONFIG[:use_gse] == nil

USING_RITES = APP_CONFIG[:theme] && (APP_CONFIG[:theme] == 'default' || APP_CONFIG[:theme] == 'rites')
NOT_USING_RITES = !USING_RITES

NOT_USING_JNLPS = APP_CONFIG[:runnables_use] && APP_CONFIG[:runnables_use] != 'otrunk_jnlp'
USING_JNLPS = !NOT_USING_JNLPS

if ActiveRecord::Base.configurations['itsi'] && ActiveRecord::Base.configurations['itsi']['asset_url']
  require 'uri'
  ITSI_ASSET_URL = URI.parse(ActiveRecord::Base.configurations['itsi']['asset_url'].strip) if ActiveRecord::Base.configurations['itsi']['asset_url']
else
  ITSI_ASSET_URL = nil
end

if APP_CONFIG[:top_level_container_name]
  TOP_LEVEL_CONTAINER_NAME = APP_CONFIG[:top_level_container_name]
else
  TOP_LEVEL_CONTAINER_NAME = 'investigation'
end

TOP_LEVEL_CONTAINER_CLASS       = TOP_LEVEL_CONTAINER_NAME.camelize.constantize

TOP_LEVEL_CONTAINER_SYM         = TOP_LEVEL_CONTAINER_NAME.to_sym

TOP_LEVEL_CONTAINER_NAME_PLURAL = TOP_LEVEL_CONTAINER_NAME.pluralize

TOP_LEVEL_CONTAINER_SYM_PLURAL  = TOP_LEVEL_CONTAINER_NAME_PLURAL.to_sym
