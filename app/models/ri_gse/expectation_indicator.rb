class RiGse::ExpectationIndicator < ActiveRecord::Base
  set_table_name "ri_gse_expectation_indicators"

  # belongs_to :user
  belongs_to :expectation, :class_name => 'RiGse::Expectation'
  has_one :expectation_stem, :class_name => 'RiGse::ExpectationStem', :through => :expectation
  # has_many :grade_span_expectations, :class_name => 'RiGse::GradeSpanExpectation', :through => :expectation

  acts_as_replicatable
  
  include Changeable
  
end
