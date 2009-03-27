class Expectation < ActiveRecord::Base
  belongs_to :user
  belongs_to :expectation_stem
  belongs_to :grade_span_expectation
  has_many   :expectation_indicators
  acts_as_replicatable
  
  include Changeable
  
end
