class AttachedFile < ActiveRecord::Base
  
  has_attached_file :attachment
  
  belongs_to :user
  belongs_to :attachable, :polymorphic => true
  
  validates_presence_of :user_id, :name, :attachable_type, :attachable_id
  
  def editable_by?(other_user)
    self.user == other_user || other_user.has_role?("admin")
  end
  
end
