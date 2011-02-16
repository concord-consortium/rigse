class AttachedFile < ActiveRecord::Base
  include Changeable
    
  has_attached_file :attachment
  
  belongs_to :user
  belongs_to :attachable, :polymorphic => true
  
  validates_presence_of :user_id, :name, :attachable_type, :attachable_id

end
