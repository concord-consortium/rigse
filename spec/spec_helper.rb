ENV["RAILS_ENV"] ||= 'test'

require 'rubygems'
require 'spork'
require 'spork/ext/ruby-debug'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  # This file is copied to ~/spec when you run 'ruby script/generate rspec'
  # from the project root directory.

  require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))

  # log all rails logger calls to STDOUT
  ActiveRecord::Base.logger = Logger.new(STDOUT)

  require 'rspec'
  require 'rspec/rails'
  require 'rspec/mocks'

  # *** customizations ***

  require 'remarkable_activerecord'

  include AuthenticatedTestHelper
  include AuthenticatedSystem

  require 'factory_girl'
  @factories = Dir.glob(File.join(File.dirname(__FILE__), '../factories/*.rb')).each { |f| require(f) }

  if ActiveRecord::Migrator.new(:up, ::Rails.root.to_s + "/db/migrate").pending_migrations.empty?
    if Probe::ProbeType.count == 0
      puts
      puts "*** Probe configuration models need to be loaded into the test database to run the tests"
      puts "*** run: rake db:test:prepare"
      puts
      exit
    end
  else
    puts
    puts "*** pending migrations need to be applied to run the tests"
    puts "*** run: rake db:test:prepare"
    puts
    exit
  end

  Dir.glob(File.dirname(__FILE__) + "/support/*.rb").each { |f| require(f) }

  # *** end of customizations ***

  RSpec.configure do |config|
    config.use_transactional_fixtures = true
    config.use_instantiated_fixtures  = false
    config.fixture_path = ::Rails.root.to_s + '/spec/fixtures/'
  end

  # FIXME Somehow using webrat kills calling .id on ActiveRecord objects...
  # example, in a test:
  #    model = Embeddable::MwModelerPage.find(:first)
  #    my_id = model.id   <==== throws NoMethodError
  #    my_id = model[:id] <==== works fine
  # require "webrat"
  # Webrat.configure do |config|
  #   config.mode = :rails
  # end

end

Spork.each_run do

end
