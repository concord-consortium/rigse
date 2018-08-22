# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a
# newer version of cucumber-rails. Consider adding your own code to a new file
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.

require 'rubygems'

ENV['RAILS_ENV'] = 'cucumber'
require File.expand_path('../../../spec/spec_helper_common.rb', __FILE__)

require 'cucumber/rails'

require 'cucumber/rails/capybara/javascript_emulation' # Lets you click links with onclick javascript handlers without using @culerity or @javascript
require 'cucumber/rails/capybara/select_dates_and_times'

require 'email_spec'
require 'email_spec/cucumber'

require 'cucumber/formatter/unicode'
require 'cucumber/rspec/doubles'
require 'rspec/expectations'

require 'capybara-screenshot/cucumber'
require_relative 'capybara_initializer'

Capybara::Screenshot.prune_strategy = :keep_last_run
Capybara::Screenshot.register_filename_prefix_formatter(:cucumber) do |scenario|
  "screenshot_#{scenario.title.gsub(' ', '-').gsub(/^.*\/spec\//,'')}"
end

CapybaraInitializer.configure do |config|
  config.headless = ENV.fetch('HEADLESS', true) != 'false'
  config.context = ENV['DOCKER'].present? ? :docker : nil
end

include SolrSpecHelper
solr_setup
clean_solar_index
reindex_all

# so we can use things like dom_id_for
include ApplicationHelper

# share the db connections between the test thread and the server thread to fix MySQL errors in tests
class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || ConnectionPool::Wrapper.new(:size => 1) { retrieve_connection }
  end
end
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

# By default, any exception happening in your Rails application will bubble up
# to Cucumber so that your scenario will fail. This is a different from how 
# your application behaves in the production environment, where an error page will 
# be rendered instead.
#
# Sometimes we want to override this default behaviour and allow Rails to rescue
# exceptions and display an error page (just like when the app is running in production).
# Typical scenarios where you want to do this is when you test your error pages.
# There are two ways to allow Rails to rescue exceptions:
#
# 1) Tag your scenario (or feature) with @allow-rescue
#
# 2) Set the value below to true. Beware that doing this globally is not
# recommended as it will mask a lot of errors for you!
#
ActionController::Base.allow_rescue = false

# Remove/comment out the lines below if your app doesn't have a database.
# For some databases (like MongoDB and CouchDB) you may need to use :truncation instead.
# rigse_tables = %w{
#   ri_gse_assessment_targets
#   ri_gse_big_ideas
#   ri_gse_domains
#   ri_gse_expectations
#   ri_gse_expectation_indicators 
#   ri_gse_expectation_stems
#   ri_gse_grade_span_expectations
#   ri_gse_knowledge_statements
#   ri_gse_unifying_themes
#   ri_gse_assessment_target_unifying_themes
# }
begin
  # DatabaseCleaner.strategy = :truncation, { :except => (rigse_tables) }
  DatabaseCleaner.strategy = :transaction
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

# You may also want to configure DatabaseCleaner to use different strategies for certain features and scenarios.
# See the DatabaseCleaner documentation for details. Example:
#
Before('@no-txn') do
  # { :except => [:widgets] } may not do what you expect here
  # as tCucumber::Rails::Database.javascript_strategy overrides
  # this setting.
  DatabaseCleaner.strategy = :truncation
end

Before('~@no-txn') do
  DatabaseCleaner.strategy = :transaction
end


# Possible values are :truncation and :transaction
# The :transaction strategy is faster, but might give you threading problems.
# See https://github.com/cucumber/cucumber-rails/blob/master/features/choose_javascript_database_strategy.feature
Cucumber::Rails::Database.javascript_strategy = :transaction
# Cucumber::Rails::Database.javascript_strategy = :truncation, { :except => (rigse_tables) }

APP_CONFIG[:theme] = 'xproject' #lots of tests seem to be broken if we try to use another theme

World(RSpec::ActiveModel::Mocks)
World(RSpec::Mocks::ExampleMethods)

# Make visible for testing
ApplicationController.send(:public, :logged_in?, :current_visitor)
