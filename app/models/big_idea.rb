class BigIdea < ActiveRecord::Base
  belongs_to :user
  belongs_to :unifying_theme
  has_many :assessment_targets, :through => :unifying_theme
  
  acts_as_replicatable
  
  include Changeable
  
end
