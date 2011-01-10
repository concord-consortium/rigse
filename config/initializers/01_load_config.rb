include AppSettings
APP_CONFIG = AppSettings.load_app_settings

APP_CONFIG[:use_gse] = true if APP_CONFIG[:use_gse] == nil

USING_RITES = APP_CONFIG[:theme] && (APP_CONFIG[:theme] == 'default' || APP_CONFIG[:theme] == 'rites')
NOT_USING_RITES = !USING_RITES

NOT_USING_JNLPS = APP_CONFIG[:runnables_use] && APP_CONFIG[:runnables_use] == 'browser'
USING_JNLPS = !NOT_USING_JNLPS

if ActiveRecord::Base.configurations['itsi'] && ActiveRecord::Base.configurations['itsi']['asset_url']
  require 'uri'
  ITSI_ASSET_URL = URI.parse(ActiveRecord::Base.configurations['itsi']['asset_url'].strip) if ActiveRecord::Base.configurations['itsi']['asset_url']
else
  ITSI_ASSET_URL = nil
end
