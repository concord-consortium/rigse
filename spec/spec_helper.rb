ENV["RAILS_ENV"] = 'test'

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/initializers/'
  add_filter '/features/'
  add_filter '/factories/'
  add_filter '/config/'
end

require_relative 'spec_helper_common'
require_relative 'spec_helper_pundit'
