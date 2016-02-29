puts "loading version from version.yml"
begin
  yaml_file_path = File.join(Rails.root, 'config', 'version.yml')
  yaml_config = YAML.load_file(yaml_file_path)
  ENV['CC_PORTAL_VERSION'] = yaml_config['version']
rescue Exception => e
  # no known version
  ENV['CC_PORTAL_VERSION'] = 'unknown'
end
