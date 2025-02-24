require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

# Patch for ActiveSupport LoggerThreadSafeLevel issue in Ruby 3.2+
require "logger"
module ActiveSupport
  module LoggerThreadSafeLevel
    Logger = ::Logger
  end
end


require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])
require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
