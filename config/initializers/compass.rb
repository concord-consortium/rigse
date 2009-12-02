require 'compass'

location_hash = {
  "#{RAILS_ROOT}/public/stylesheets/sass" => "#{RAILS_ROOT}/public/stylesheets"
}
 
# My fork of theme_support has a Themed model due to a name collision in my project http://github.com/bullrico/theme_support/tree/master
# Separate sass and compiled dirs, so theme_support only copies over compiled to the public cache dir
Theme.find_all.map(&:name).each do |theme|
  location_hash["#{RAILS_ROOT}/themes/#{theme}/stylesheets/sass"] = "#{RAILS_ROOT}/themes/#{theme}/stylesheets/compiled"
end
 
Sass::Plugin.options[:template_location] = location_hash
 
Compass::Frameworks::ALL.each do |framework|
  Sass::Plugin.options[:template_location][framework.stylesheets_directory] = "#{RAILS_ROOT}/public/stylesheets"
end

# If you have any compass plugins, require them here.
Compass.configuration do |config|
  config.project_path = RAILS_ROOT
  config.sass_dir = "public/stylesheets/sass"
  config.css_dir = "public/stylesheets"
end
Compass.configure_sass_plugin!
