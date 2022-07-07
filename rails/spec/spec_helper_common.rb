require File.expand_path("../../config/environment", __FILE__)
require 'factory_bot'
FactoryBot.definition_file_paths = %w(factories)

require 'webdrivers'
require 'rspec/rails'
require 'rspec/mocks'
require 'capybara/rspec'
require 'capybara/rails'
require 'webmock/rspec'
require 'capybara-screenshot/rspec'
require 'remarkable_activerecord'
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}


# Allow reporting to codeclimate
WebMock.disable_net_connect!(allow_localhost: true, :allow =>
                                [   "#{SolrSpecHelper::SOLR_HOST}:#{SolrSpecHelper::SOLR_PORT}",
                                    "codeclimate.com",
                                    'host.docker.internal:9515',
                                    'chromedriver.storage.googleapis.com'
                                ]
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
  def self.connection
    @@shared_connection
  end

  def self.set_shared_connection
    @@shared_connection = ConnectionPool::Wrapper.new(:size => 1) { retrieve_connection }
  end

  def self.with_database(database)
    previous = current_database_configuration_name
    establish_connection(database.to_sym)
    set_shared_connection
    yield
  ensure
    establish_connection(previous.to_sym)
    set_shared_connection
  end

  def self.current_database_configuration_name
    configurations.to_h.find { |_k, v| v['database'] == connection.current_database }[0]
  end
end
ActiveRecord::Base.set_shared_connection

#The above monkeypatch which causes all threads to share the same database connection sometimes causes thread safety related failures. The below monkeypatch attempts to resolve some of those with a mutex. Specifically we were  getting "Mysql2::Error: This connection is in use by..." errors until implementing this fix. This code (and the shared connection code above) can be removed at Rails 5.1 where these issues were solved in Rails & Capybara directly.

module MutexLockedQuerying
  @@semaphore = Mutex.new

  def query(*)
    @@semaphore.synchronize { super }
  end
end

Mysql2::Client.prepend(MutexLockedQuerying)

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.mock_with :rspec

  config.around(:example, type: :feature) do |example|
    ApplicationRecord.with_database('feature_test') { example.run }
  end

  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = Rails.env == 'test'
  config.infer_spec_type_from_file_location!
  config.expose_current_running_example_as :example

  config.include Sprockets::Rails::Helper
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include VerifyAndResetHelpers
  config.include FeatureHelper

  config.infer_spec_type_from_file_location!

  # Stub all elasticsearch posts from learner update_report_model_cache
  config.before(:each) do
    WebMock.stub_request(:post, /#{ENV['ELASTICSEARCH_URL']}/).to_return(status: 200, body: "", headers: {})
  end
end

begin
  ActiveRecord::Migration.check_pending!
rescue => exception
  puts
  puts "*** pending migrations need to be applied to run the tests"
  puts "*** run: rake db:migrate; rake db:test:prepare; rake db:feature_test:prepare; RAILS_ENV=cucumber rake app:setup:create_default_data"
  puts "RAILS_ENV: #{ENV['RAILS_ENV']}"
  puts "Rails.env: #{Rails.env}"
  puts "Database: #{ApplicationRecord.connection.current_database}"
  puts
  exit 1
end

# Prevent Factory definitions from being loaded multiple times
# But allow access to cucumber specs and db prep
@defs_loaded ||= FactoryBot.find_definitions and true
