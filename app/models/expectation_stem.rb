class ExpectationStem < ActiveRecord::Base
  belongs_to :user
  has_many      :expectations
  belongs_to    :grade_span_expectation
end
