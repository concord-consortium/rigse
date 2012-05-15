class RiGse::Expectation < ActiveRecord::Base
  self.table_name = "ri_gse_expectations"

  # belongs_to :user
  belongs_to :grade_span_expectation, :class_name => 'RiGse::GradeSpanExpectation'
  belongs_to :expectation_stem, :class_name => 'RiGse::ExpectationStem'
  has_many :expectation_indicators, :class_name => 'RiGse::ExpectationIndicator'

  acts_as_replicatable
  
  include Changeable
  
end
