class ExpectationStem < ActiveRecord::Base
  has_many      :expectations
  belongs_to    :grade_span_expectation
end
