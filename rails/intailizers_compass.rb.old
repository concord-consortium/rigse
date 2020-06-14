require 'compass'

location_hash = {
  "#{::Rails.root.to_s}/public/stylesheets/sass" => "#{::Rails.root.to_s}/public/stylesheets"
}
 
# My fork of theme_support has a Themed model due to a name collision in my project http://github.com/bullrico/theme_support/tree/master
# Separate sass and compiled dirs, so theme_support only copies over compiled to the public cache dir
Theme.find_all.map(&:name).each do |theme|
  location_hash["#{::Rails.root.to_s}/themes/#{theme}/stylesheets/sass"] = "#{::Rails.root.to_s}/themes/#{theme}/stylesheets/compiled"
end
 
Sass::Plugin.options[:template_location] = location_hash
 
Compass::Frameworks::ALL.each do |framework|
  Sass::Plugin.options[:template_location][framework.stylesheets_directory] = "#{::Rails.root.to_s}/public/stylesheets"
end

# If you have any compass plugins, require them here.
Compass.configuration do |config|
  config.project_path = ::Rails.root.to_s
  config.sass_dir = "public/stylesheets/sass"
  config.css_dir = "public/stylesheets"
end
Compass.configure_sass_plugin!
