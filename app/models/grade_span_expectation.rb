class GradeSpanExpectation < ActiveRecord::Base
  belongs_to              :user
  has_many                :expectations
  belongs_to              :assessment_target
  has_many                :unifying_themes, :through => :assessment_target
  acts_as_replicatable
  
  default_scope :conditions => "grade_span LIKE '%9-11%'"
  
  include Changeable
  
  self.extend SearchableModel
  
  @@searchable_attributes = %w{grade_span}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  
end
