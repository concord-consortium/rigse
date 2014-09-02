# Load the rails application
require File.expand_path('../application', __FILE__)

JRUBY = defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'

require 'yaml'
YAML::ENGINE.yamler = "psych"

# Load the app's custom environment variables here, so that they are loaded before environments/*.rb
app_environment_variables = File.join(Rails.root, 'config', 'app_environment_variables.rb')
if File.exists?(app_environment_variables)
  load(app_environment_variables)
else
  # TODO: Should we just die here otherwise?
  puts "please create the file #{app_environment_variables}, or set ENV"
end

# Initialize the rails application
RailsPortal::Application.initialize!
