ENV["RAILS_ENV"] = 'test'

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
  Factory.build(subject_class_factory)
end

def factory_stubbed
  Factory.build_stubbed(subject_class_factory)
end

def factory_create
  Factory.create(subject_class_factory)
end
