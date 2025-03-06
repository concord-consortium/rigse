# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a
# newer version of cucumber-rails. Consider adding your own code to a new file
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.

require 'rubygems'
require 'simplecov'
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

ENV['RAILS_ENV'] = 'cucumber'
ENV['RAILS_SECRET_KEY_BASE'] = 'a4c92197b158570f42dd9fb0124dfc96ba858167187b6afaa8f10d1c2c542afa3721737874e49cb0dcd71f58f78c4d3f4dc14e57d67ae110e15114628cee8a43'

require 'cucumber/rails'
require 'cucumber/rails/capybara/javascript_emulation' # Lets you click links with onclick javascript handlers without using @culerity or @javascript
require 'cucumber/rails/capybara/select_dates_and_times'

require 'webmock/cucumber'

require 'email_spec'
require 'email_spec/cucumber'

require 'cucumber/formatter/unicode'
require 'cucumber/rspec/doubles'
require 'rspec/expectations'

require 'capybara-screenshot/cucumber'

Capybara::Screenshot.prune_strategy = :keep_last_run
Capybara::Screenshot.register_filename_prefix_formatter(:cucumber) do |scenario|
  "screenshot_#{scenario.name.gsub(' ', '-').gsub(/^.*\/spec\//,'')}"
end

# so we can use things like dom_id_for
include ApplicationHelper

DatabaseCleaner.strategy = :transaction
Cucumber::Rails::Database.javascript_strategy = :transaction

APP_CONFIG[:theme] = 'xproject' #lots of tests seem to be broken if we try to use another theme

World(RSpec::ActiveModel::Mocks)
World(RSpec::Mocks::ExampleMethods)

# Make visible for testing
ApplicationController.send(:public, :logged_in?, :current_visitor)

# Note: It is important that this come after cucumber rails db
# config above. We define our own shared connection strategy here
# and it is inteded to override a portion of the shared strategy that
# cucumber rails defines. Incorrect order results in mysql errors.
# More info: https://github.com/concord-consortium/rigse/pull/559
require File.expand_path('../../../spec/spec_helper_common.rb', __FILE__)

include SolrSpecHelper
solr_setup
clean_solar_index
reindex_all

# adapted from https://www.testdevlab.com/blog/2018/02/adding-browser-logs-to-your-capybara-cucumber-ui-test-report/
After do |scenario|
  if scenario.failed?
    add_browser_logs(scenario)
  end
 end

def add_browser_logs(scenario)
  if page.driver.browser.respond_to? :manage
    time_now = Time.now
    # Getting current URL
    current_url = Capybara.current_url.to_s
    # Gather browser logs
    logs = page.driver.browser.logs.get(:browser).map {|line| [line.level, line.message]}
    # Remove warnings and info messages
    logs.reject! { |line| ['WARNING', 'INFO'].include?(line.first) }
    logs.any? == true
    puts "BROWSER ERRORS for \"#{scenario.name}\" (#{current_url}):\n  - " + logs.join("\n  - ")
  end
end
