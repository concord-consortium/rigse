class ExpectationStem < ActiveRecord::Base
  belongs_to              :user
  has_many                :expectations
  acts_as_replicatable
end
