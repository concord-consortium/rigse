class AuthorNote < ActiveRecord::Base
  belongs_to :user
  belongs_to :authored_entity, :polymorphic => true
  acts_as_replicatable
  include Changeable
end
