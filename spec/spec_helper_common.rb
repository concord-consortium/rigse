require 'simplecov'
require File.expand_path("../../config/environment", __FILE__)
require 'factory_girl'
require 'rspec/rails'
require 'rspec/mocks'
require 'capybara/rspec'
require 'capybara/rails'
require 'webmock/rspec'
require 'capybara-screenshot/rspec'
require 'remarkable_activerecord'
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

SimpleCov.start do
  merge_timeout 3600
  
  add_filter '/spec/'
  add_filter '/initializers/'
  add_filter '/features/'
  add_filter '/factories/'
  add_filter '/config/'

  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Helpers', 'app/helpers'
  add_group 'Views', 'app/views'
  add_group 'Policies', 'app/policies'
  add_group 'Services', 'app/services'
  add_group 'Lib', 'lib'
end

# Mute FactoryGirl deprecation warnings...
ActiveSupport::Deprecation.behavior = lambda do |msg, stack|
  unless /FactoryGirl|after_create/ =~ msg
    ActiveSupport::Deprecation::DEFAULT_BEHAVIORS[:stderr].call(msg,stack) # whichever handlers you want - this is the default
  end
end

# Allow reporting to codeclimate
WebMock.disable_net_connect!(allow_localhost: true, :allow =>
                                [   "#{SolrSpecHelper::SOLR_HOST}:#{SolrSpecHelper::SOLR_PORT}",
                                    "codeclimate.com",
                                    'host.docker.internal:9515' ]
                            )

Capybara::Screenshot.prune_strategy = :keep_last_run

Dir.mkdir "tmp/capybara" rescue nil
Capybara.save_path = "tmp/capybara"

include AuthenticatedSystem

module VerifyAndResetHelpers
  def verify(object)
    RSpec::Mocks.proxy_for(object).verify
  end

  def reset(object)
    RSpec::Mocks.proxy_for(object).reset
  end
end

RSpec.configure do |config|
  config.mock_with :rspec

  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = Rails.env == 'test'
  config.infer_spec_type_from_file_location!
  config.expose_current_running_example_as :example

  config.include Sprockets::Helpers::RailsHelper
  config.include Devise::TestHelpers, :type => :controller
  config.include VerifyAndResetHelpers

  config.infer_spec_type_from_file_location!
end

if ActiveRecord::Migrator.new(:up, ::Rails.root.to_s + "/db/migrate").pending_migrations.present?
  puts
  puts "*** pending migrations need to be applied to run the tests"
  puts "*** run: rake db:test:prepare"
  puts "RAILS_ENV: #{ENV['RAILS_ENV']}"
  puts "Rails.env: #{Rails.env}"
  puts "Database: #{ActiveRecord::Base.connection.current_database}"
  puts
  exit 1
end

# I don't think this is necessary anymore with the latest factory_girl
FactoryGirl.definition_file_paths = %w(factories)
FactoryGirl.find_definitions
