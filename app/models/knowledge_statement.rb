class KnowledgeStatement < ActiveRecord::Base
  belongs_to :user
  acts_as_replicatable
end
