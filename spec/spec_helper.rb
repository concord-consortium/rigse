ENV["RAILS_ENV"] ||= 'test'

require 'rubygems'
require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  # This file is copied to ~/spec when you run 'ruby script/generate rspec'
  # from the project root directory.
  
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
  
  require 'spec/autorun'
  require 'spec/rails'
  
  # *** customizations ***
  
  require 'remarkable_rails'
  
  include AuthenticatedTestHelper
  include AuthenticatedSystem
  
  require 'factory_girl'
  @factories = Dir.glob(File.join(File.dirname(__FILE__), '../factories/*.rb'))
  
  unless ActiveRecord::Migrator.new(:up, RAILS_ROOT + "/db/migrate").pending_migrations.empty?
    puts "migrations need to be run: rake db:test:prepare"
  end

  Dir.glob(File.dirname(__FILE__) + "/support/*.rb").each { |f| require(f) }

  # *** end of customizations ***
  
  Spec::Runner.configure do |config|
    config.use_transactional_fixtures = true
    config.use_instantiated_fixtures  = false
    config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  end
    
end

Spork.each_run do
  @factories.each { |f| load f }
end
