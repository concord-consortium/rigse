class GradeSpanExpectation < ActiveRecord::Base
  belongs_to              :user
  has_many                :expectations
  belongs_to              :assessment_target
  has_many                :unifying_themes, :through => :assessment_target
  acts_as_replicatable
  
  #:default_scope :conditions => "grade_span LIKE '%9-11%'"  
  # above was causing errors on otto when running setup-from-scratch:
  # 
  #     undefined method `grade_span LIKE '%9-11%'=' for #<GradeSpanExpectation:0xb6a60354>
  #     ...(Additional Rails Framework traces removed)
  #     /web/rites.concord.org/releases/20090402170801/lib/parser.rb:292:in `new'
  #
  # removing the conditions solved the isssue.
  
  include Changeable
  
  self.extend SearchableModel
  
  @@searchable_attributes = %w{grade_span}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  
end
