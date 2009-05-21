class GradeSpanExpectation < ActiveRecord::Base
  belongs_to :user

  has_many :expectations
  has_many :expectation_stems, :through => :expectations
  has_many :expectation_indicators, :through => :expectations

  belongs_to :assessment_target
  has_many :unifying_themes, :through => :assessment_target
  has_many :knowledge_statements, :through => :assessment_target

  acts_as_replicatable
  
  # our models are a bit to nested for this to work reasonably I think...
  # named_scope :grade_span_and_domain, lambda { |gs,domain_id|
  #   {
  #     :joins => [:assessment_target, :knowledge_statements],
  #     :conditions => { 'knowledge_statements.domain_id' => domain_id }  
  #   }
  # }
  
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
  
  def description
    "#{assessment_target.description}"
  end
  
  def domain
    return knowledge_statements[0].domain
  end
  
  def theme_keys
    unifying_themes.map{ |t| t.key}.join("+")
  end
  
  def gse_key
    return "#{domain.key}#{assessment_target.number} (#{grade_span}) #{theme_keys}"
  end
  
  @@searchable_attributes = %w{grade_span}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end
  
end
