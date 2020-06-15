# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'
# require 'ci/reporter/rake/rspec'     # use this if you're using RSpec
# require 'ci/reporter/rake/cucumber'  # use this if you're using Cucumber

begin
  require "rspec/core/rake_task"
rescue LoadError
end

include Rake::DSL

RailsPortal::Application.load_tasks
