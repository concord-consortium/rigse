class RiGse::ExpectationStem < ActiveRecord::Base
  set_table_name "ri_gse_expectation_stems"

  # belongs_to :user
  has_many :expectations, :class_name => 'RiGse::Expectation'
  has_many :grade_span_expectations, :class_name => 'RiGse::GradeSpanExpectation', :through => :expectations
  has_many :expectation_indicators, :class_name => 'RiGse::ExpectationIndicator', :through => :expectations

  acts_as_replicatable
  
  include Changeable
  
end
