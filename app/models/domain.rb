class Domain < ActiveRecord::Base
  belongs_to :user
  has_many :knowledge_statements
end
