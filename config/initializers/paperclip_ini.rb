config_file ="#{::Rails.root.to_s}/config/paperclip.yml"
if File.exists?(config_file)
    Rails.logger.info("configuring paperclip from #{config_file}")
    c = YAML::load(File.open(config_file))
    # TODO: do we want to scope to RAILS_ENV?
    c.each do |key,val|
      Paperclip::Attachment.default_options[key.to_sym] = val
    end
else
  Rails.logger.info("no configuration file for Paperclip. Using defaults. (no s3 storage)")
end