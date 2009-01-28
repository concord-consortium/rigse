class Expectation < ActiveRecord::Base
  belongs_to :user
  belongs_to :expectation_stem
  acts_as_replicatable
end
