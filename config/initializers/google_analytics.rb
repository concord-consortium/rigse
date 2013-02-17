config_file ="#{::Rails.root.to_s}/config/google_analytics.yml"
if File.exists?(config_file) && Rails.env.production?
    c = YAML::load(File.open(config_file))
    if c && c[:account]
      GOOGLE_ANALYTICS_ACCOUNT = c[:account]
    end
end
USING_GOOGLE_ANALYTICS = !!defined?(GOOGLE_ANALYTICS_ACCOUNT)
