class ExpectationIndicator < ActiveRecord::Base
  # belongs_to :user
  belongs_to :expectation
  has_one :expectation_stem, :through => :expectation
  # has_many :grade_span_expectations, :through => :expectation

  acts_as_replicatable
  
  include Changeable
  
end
