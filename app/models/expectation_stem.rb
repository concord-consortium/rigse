class ExpectationStem < ActiveRecord::Base
  belongs_to              :user
  has_many                :expectations
  has_and_belongs_to_many :grade_span_expectations
  acts_as_replicatable
end
