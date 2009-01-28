class KnowledgeStatement < ActiveRecord::Base
  belongs_to :user
  belongs_to :domain
  acts_as_replicatable
end
