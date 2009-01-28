class GradeSpanExpectation < ActiveRecord::Base
  belongs_to :user
  has_many    :expectation_stems
  has_many    :big_ideas
  belongs_to  :assessment_target
end
