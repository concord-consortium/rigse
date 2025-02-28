require File.expand_path('../app_settings', __FILE__)

module LoadConfig
  extend self

  include AppSettings

  def self.load!
    app_config = load_app_settings

    # set the defaults
    # Rails was complaining about all the changes being made to a "constant"
    app_config = {
      :recent_activity_on_login => true,
      :top_level_container_name => 'investigation',
      :host => nil
    }.merge(app_config)

    site_url = URI.parse(app_config[:site_url])
    app_config[:protocol] = site_url.scheme
    app_config[:host] = site_url.to_s.gsub("http://","").gsub("https://","")

    Object.const_set(:USING_RITES, app_config[:theme] && (app_config[:theme] == 'default' || app_config[:theme] == 'rites'))
    Object.const_set(:NOT_USING_RITES, !USING_RITES)

    Object.const_set(:APP_CONFIG, app_config) # It's constant now

    Object.const_set(:TOP_LEVEL_CONTAINER_NAME, APP_CONFIG[:top_level_container_name])
    Object.const_set(:TOP_LEVEL_CONTAINER_SYM, TOP_LEVEL_CONTAINER_NAME.to_sym)
    Object.const_set(:TOP_LEVEL_CONTAINER_NAME_PLURAL, TOP_LEVEL_CONTAINER_NAME.pluralize)
    Object.const_set(:TOP_LEVEL_CONTAINER_SYM_PLURAL, TOP_LEVEL_CONTAINER_NAME_PLURAL.to_sym)
  end
end

LoadConfig.load!
