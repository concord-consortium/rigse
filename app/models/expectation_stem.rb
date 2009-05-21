class ExpectationStem < ActiveRecord::Base
  belongs_to :user
  has_many :expectations
  has_many :grade_span_expectations, :through => :expectations
  has_many :expectation_indicators, :through => :expectations

  acts_as_replicatable
  
  include Changeable
  
end
