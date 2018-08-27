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

CapybaraInitializer.configure do |config|
  config.headless = ENV.fetch('HEADLESS', true) != 'false'
  config.context = ENV['DOCKER'].present? ? :docker : nil
end

# share the db connections between the test thread and the server thread to fix MySQL errors in tests
class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || ConnectionPool::Wrapper.new(:size => 1) { retrieve_connection }
  end
end
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

#The above monkeypatch which causes all threads to share the same database connection sometimes causes thread safety related failures. The below monkeypatch attempts to resolve some of those with a mutex. Specifically we were  getting "Mysql2::Error: This connection is in use by..." errors until implementing this fix. This code (and the shared connection code above) can be removed at Rails 5.1 where these issues were solved in Rails & Capybara directly.

module MutexLockedQuerying
  @@semaphore = Mutex.new

  def query(*)
    @@semaphore.synchronize { super }
  end
end

Mysql2::Client.prepend(MutexLockedQuerying)

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
