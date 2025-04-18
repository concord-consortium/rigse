# Load the rails application
require File.expand_path('../application', __FILE__)

# YAML::ENGINE has been removed in Ruby 2.2. According to https://bugs.ruby-lang.org/issues/8344
# Psych is now the default engine anyway.
# require 'yaml'
# YAML::ENGINE.yamler = "psych"

Rails.application.configure do
  config.active_support.to_time_preserves_timezone = :zone
end

# Initialize the rails application
RailsPortal::Application.initialize!
