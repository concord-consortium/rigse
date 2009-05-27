class KnowledgeStatement < ActiveRecord::Base
  belongs_to :user
  belongs_to :domain
  has_many :assessment_targets
  has_many :unifying_themes, :through => :assessment_targets
  has_many :grade_span_expectations, :through => :assessment_targets

  acts_as_replicatable

  include Changeable

end
