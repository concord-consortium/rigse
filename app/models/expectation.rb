class Expectation < ActiveRecord::Base
  belongs_to :user
  belongs_to :grade_span_expectation
  belongs_to :expectation_stem
  has_many   :expectation_indicators

  acts_as_replicatable
  
  include Changeable
  
end
