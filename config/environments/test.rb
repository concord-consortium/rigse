# Settings specified here will take precedence over those in config/environment.rb
puts "loading test environment"
# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

config.cache_classes = false

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# Tell Action Mailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test
config.action_mailer.perform_deliveries = true
# current customizations below this line ...

# Install the gems required for testing:
#
#   sudo env RAILS_ENV=test rake gems:install
#

# See: http://wiki.github.com/dchelimsky/rspec/configgem-for-rails

config.gem 'cucumber',         :lib => false, :version => '>=0.7.3' unless File.directory?(File.join(Rails.root, 'vendor/plugins/cucumber'))
config.gem 'cucumber-rails',   :lib => false, :version => '>=0.3.1' unless File.directory?(File.join(Rails.root, 'vendor/plugins/cucumber-rails'))
config.gem 'database_cleaner', :lib => false, :version => '>=0.5.0' unless File.directory?(File.join(Rails.root, 'vendor/plugins/database_cleaner'))
config.gem 'capybara',         :lib => false, :version => '=0.3.9' unless File.directory?(File.join(Rails.root, 'vendor/plugins/capybara'))
config.gem 'rspec',            :lib => false, :version => '=1.3.1' unless File.directory?(File.join(Rails.root, 'vendor/plugins/rspec'))
config.gem 'rspec-rails',      :lib => false, :version => '=1.3.3' unless File.directory?(File.join(Rails.root, 'vendor/plugins/rspec-rails'))
config.gem "factory_girl",                    :version => "= 1.2.3"
config.gem 'email_spec',                      :version => "= 0.3.5"
config.gem 'fakeweb',                         :version => ">=1.2.8"
# config.gem 'webrat',      :lib => false,        :version => '>=0.5.3' unless File.directory?(File.join(Rails.root, 'vendor/plugins/webrat'))

# See: http://wiki.github.com/dchelimsky/rspec/spork-autospec-pure-bdd-joy
# and: http://ben.hoskings.net/2009/07/16/speedy-rspec-with-rails
config.gem "ZenTest",        :lib => false,          :version => "= 4.1.4"
config.gem "autotest-rails", :lib => false,          :version => "= 4.1.0"

# See: http://remarkable.rubyforge.org/
# and: http://github.com/carlosbrando/remarkable/tree/master
# Adds new rspec matchers for models and controllers
# as well as better support for I18n, collections, creating custom matchers 
config.gem "remarkable_rails", :lib => false,        :version => ">= 3.1.13"

config.gem "ci_reporter",      :lib => false,        :version => '=1.6.0'

config.gem "spork",            :lib => false

unless RUBY_PLATFORM =~ /java/
  # See: http://www.datanoise.com/ruby-debug/
  require 'ruby-debug'
  # Debugger.wait_connection = true
  # Debugger.stop_on_connect = true
  # Debugger.start_remote
  Debugger.start
  Debugger.settings[:autolist] = 1
  Debugger.settings[:autoeval] = 1
  Debugger.settings[:reload_source_on_change] = 1
end
