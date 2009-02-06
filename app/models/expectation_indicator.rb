class ExpectationIndicator < ActiveRecord::Base
  belongs_to :user
  belongs_to :expectation
  acts_as_replicatable
end
