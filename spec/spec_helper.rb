ENV["RAILS_ENV"] ||= 'test'

require 'spork'
require 'spork/ext/ruby-debug'

Spork.prefork do

  # This section is based on the file generated by running:
  #   rails generate rspec:install
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/mocks'
  
  # *** customizations ***
  
  # Add this to load Capybara integration:
  # The Capybara DSL is automatically mixed in to specs running in 
  # spec/requests, spec/integration or spec/acceptance.
  #
  # You can use the Capybara DSL in any rspec test if you add: 
  #  ',:type => :request'  to the describe invocation ...
  #
  require 'capybara/rspec'
  require 'capybara/rails'
  
  require 'remarkable_activerecord'
  # we have to include our extensions in the rspec configuration block
  require File.expand_path("../support/rspec_extensions", __FILE__)
  require File.expand_path("../support/authenticated_test_helper", __FILE__)
  include AuthenticatedTestHelper
  include AuthenticatedSystem

  RSpec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true

    config.include FailsInThemes
    config.include Sprockets::Helpers::RailsHelper
    config.include ThemesForRails::UrlHelpers
    config.include ThemesForRails::ActionView
  end
end

Spork.each_run do
  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

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

  require 'factory_girl'
  
  # I don't think this is necessary anymore with the latest factory_girl
  @factories = Dir.glob(File.join(File.dirname(__FILE__), '../factories/*.rb')).each { |f| require(f) }
end
