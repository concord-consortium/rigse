require 'rubygems'
require 'spork'

ENV["RAILS_ENV"] ||= 'test'
Spork.prefork do
  require File.dirname(__FILE__) + "/../config/environment"
  # require 'spec/autorun'
  require 'spec/rails'

  Spec::Runner.configure do |config|
    # not using fixtures, but these seem to apply also to factory girl
    config.use_transactional_fixtures = true 
    config.use_instantiated_fixtures  = true
    config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  end
  
end

factories = Dir["#{File.dirname(__FILE__)}/../factories/*.rb"]
Spork.each_run do
  puts "reloading..."
  factories.each {|f| load f}
end
