ENV["RAILS_ENV"] = 'test'

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

require_relative 'spec_helper_common'
require_relative 'spec_helper_pundit'

def klass_name
  described_class.name.underscore
end

def subject_class
  klass_name.to_sym
end

def subject_class_factory
  klass_name.split('/').last.to_sym
end

def factory
  FactoryGirl.build(subject_class_factory)
end

def factory_stubbed
  FactoryGirl.build_stubbed(subject_class_factory)
end

def factory_create
  FactoryGirl.create(subject_class_factory)
end
