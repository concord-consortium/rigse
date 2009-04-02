class GradeSpanExpectation < ActiveRecord::Base
  belongs_to              :user
  has_many                :expectations
  belongs_to              :assessment_target
  has_many                :unifying_themes, :through => :assessment_target
  acts_as_replicatable
  
  # this was causing errors on otto when running setup-from-scratch:
  # here is error-output
        # undefined method `grade_span LIKE '%9-11%'=' for #<GradeSpanExpectation:0xb6a60354>
        # /web/rites.concord.org/releases/20090402170801/vendor/rails/activerecord/lib/active_record/attribute_methods.rb:255:in `method_missing'
        # /web/rites.concord.org/releases/20090402170801/vendor/rails/activerecord/lib/active_record/base.rb:2440:in `send'
        # /web/rites.concord.org/releases/20090402170801/vendor/rails/activerecord/lib/active_record/base.rb:2440:in `initialize'
        # /web/rites.concord.org/releases/20090402170801/vendor/rails/activerecord/lib/active_record/base.rb:2440:in `each'
        # /web/rites.concord.org/releases/20090402170801/vendor/rails/activerecord/lib/active_record/base.rb:2440:in `initialize'
        # /web/rites.concord.org/releases/20090402170801/lib/parser.rb:292:in `new'
  #
  #:default_scope :conditions => "grade_span LIKE '%9-11%'"
  
  include Changeable
  
  self.extend SearchableModel
  
  @@searchable_attributes = %w{grade_span}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  
end
