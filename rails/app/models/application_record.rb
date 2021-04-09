# new base class for Rails 5 modls
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
