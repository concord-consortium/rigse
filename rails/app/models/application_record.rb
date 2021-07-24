# new base class for Rails 5 models
class ApplicationRecord < ActiveRecord::Base
  include Foo::Acts::Replicatable
  include SendUpdateEvents

  self.abstract_class = true
end
