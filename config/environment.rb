# Load the rails application
require File.expand_path('../application', __FILE__)

JRUBY = defined? RUBY_ENGINE && RUBY_ENGINE == 'jruby'
# Initialize the rails application
RailsPortal::Application.initialize!
