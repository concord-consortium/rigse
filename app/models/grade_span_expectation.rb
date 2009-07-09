class GradeSpanExpectation < ActiveRecord::Base
  # belongs_to :user

  has_many :investigations
  
  has_many :expectations
  has_many :expectation_stems, :through => :expectations
  has_many :expectation_indicators, :through => :expectations

  belongs_to :assessment_target
  has_many :knowledge_statements, :through => :assessment_target

  acts_as_replicatable
  
  
  # brittle;,because we must know too much about table names ...
  named_scope :grade_and_domain, lambda { |gs,domain_id|
    {
      :joins => "JOIN assessment_targets ON (assessment_targets.id = grade_span_expectations.assessment_target_id) JOIN knowledge_statements ON (knowledge_statements.id = assessment_targets.knowledge_statement_id)",
      :conditions =>[ 'knowledge_statements.domain_id = ? and grade_span_expectations.grade_span LIKE ?', domain_id, gs ]
    }
  }
  # 
  #:default_scope :conditions => "grade_span LIKE '%9-11%'"  
  # above was causing errors on otto when running setup-from-scratch:
  # 
  #     undefined method `grade_span LIKE '%9-11%'=' for #<GradeSpanExpectation:0xb6a60354>
  #     ...(Additional Rails Framework traces removed)
  #     /web/rites.concord.org/releases/20090402170801/lib/parser.rb:292:in `new'
  #
  # removing the conditions solved the isssue.
  #
  # What can you do with a gse instance?
  #
  # >> g.assessment_target.description
  # => " Use physical and chemical properties as determined through an investigation to identify a substance."
  # 
  # >> g.expectation_stems.collect {|es| es.description}
  # => ["Students demonstrate an understanding of characteristic properties of matter by "]
  # 
  # >> g.expectation_indicators.collect {|ei| ei.description}
  # => ["utilizing appropriate data (related to chemical and physical properties), to distinguish one substance 
  #      from another or identify an unknown substance.", "determining the degree of change in pressure of a 
  #      given volume of gas when the temperature changes incrementally (doubles, triples, etc.)."]
  # 
  # >> g.assessment_target.knowledge_statement.description
  # => " All living and nonliving things are composed of matter having characteristic properties that distinguish 
  #      one substance from another (independent of size or amount of substance)"
  # 
  # >> g.assessment_target.unifying_theme.name
  # => "Scientific Inquiry"
  # 
  # >> g.unifying_themes.collect {|ut| ut.name}
  # => ["Scientific Inquiry"]
  # 
  # >> g.unifying_themes.collect {|ut| {ut.name => ut.big_ideas.collect {|bi| bi.description}}}
  # => [{"Scientific Inquiry"=>["Collect data", "Communicate understanding & ideas", "Design, conduct, & critique investigations", 
  #     "Represent, analyze, & interpret data", "Experimental design", "Observe", "Predict", "Question and hypothesize", 
  #     "Use evidence to draw conclusions", "Use tools, & techniques", "Collect data", "Communicate understanding & ideas", 
  #     "Design, conduct, & critique investigations", "Represent, analyze, & interpret data", "Experimental design", "Observe", 
  #     "Predict", "Question and hypothesize", "Use evidence to draw conclusions", "Use tools, & techniques"]}]
  # 
  # >> puts g.unifying_themes.collect {|ut| {ut.name => ut.big_ideas.collect {|bi| bi.description}}}.to_yaml
  # --- 
  # - Scientific Inquiry: 
  #   - Collect data
  #   - Communicate understanding & ideas
  #   - Design, conduct, & critique investigations
  #   - Represent, analyze, & interpret data
  #   - Experimental design
  #   - Observe
  #   - Predict
  #   - Question and hypothesize
  #   - Use evidence to draw conclusions
  #   - Use tools, & techniques
  #   - Collect data
  #   - Communicate understanding & ideas
  #   - Design, conduct, & critique investigations
  #   - Represent, analyze, & interpret data
  #   - Experimental design
  #   - Observe
  #   - Predict
  #   - Question and hypothesize
  #   - Use evidence to draw conclusions
  #   - Use tools, & techniques
  
  include Changeable

  # it would be nice to extend SearchableModel to support this kind of spec
  # @@searchable_attributes = ['grade_span',  :include => [{:expectation_stems => :description}, {:expectation_indicators => :description} ]
  
  @@searchable_attributes = %w{grade_span gse_key}

  self.extend SearchableModel
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end

  def description
    "#{assessment_target.description}"
  end
  
  def domain
    knowledge_statements[0].domain
  end
  
  def theme_keys
    assessment_target.unifying_themes.map{ |t| t.key}.join("+")
  end
  
  def set_gse_key
    self.gse_key = "#{domain.key}#{assessment_target.knowledge_statement.number} (#{grade_span}) #{theme_keys} - #{assessment_target.number}"
    self.save
  end

end
