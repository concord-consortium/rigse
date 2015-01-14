require File.expand_path('../app_settings', __FILE__)
include AppSettings
app_config = AppSettings.load_app_settings

# set the defaults
# Rails was complaining about all the changes being made to a "constant"
app_config = {
  :use_gse => true,
  :recent_activity_on_login => true,
  :top_level_container_name => 'investigation',
  :use_jnlps => true,
  :host => nil
}.merge(app_config)

site_url = URI.parse(app_config[:site_url])
app_config[:protocol] = site_url.scheme 
app_config[:host] = site_url.to_s.gsub("http://","").gsub("https://","")

USING_RITES = app_config[:theme] && (app_config[:theme] == 'default' || app_config[:theme] == 'rites')
NOT_USING_RITES = !USING_RITES

# handle legacy configuration
if app_config[:runnables_use] && app_config[:runnables_use] != 'otrunk_jnlp'
  app_config[:use_jnlps] = false
end

APP_CONFIG = app_config # It's constant now

TOP_LEVEL_CONTAINER_NAME = APP_CONFIG[:top_level_container_name]

TOP_LEVEL_CONTAINER_SYM         = TOP_LEVEL_CONTAINER_NAME.to_sym

TOP_LEVEL_CONTAINER_NAME_PLURAL = TOP_LEVEL_CONTAINER_NAME.pluralize

TOP_LEVEL_CONTAINER_SYM_PLURAL  = TOP_LEVEL_CONTAINER_NAME_PLURAL.to_sym
