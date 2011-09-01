# This file is used by Rack-based servers to start the application.

require 'rubygems'
require 'bundler'
Bundler.require(:default, ENV['RACK_ENV'].to_sym)

require ::File.expand_path('../config/environment',  __FILE__)
run RailsPortal::Application
