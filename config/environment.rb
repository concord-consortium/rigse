# Load the rails application
require File.expand_path('../application', __FILE__)

JRUBY = defined? RUBY_ENGINE && RUBY_ENGINE == 'jruby'

require 'yaml'
YAML::ENGINE.yamler = "psych"

# Initialize the rails application
RailsPortal::Application.initialize!
