class Portal::Collaboration < ActiveRecord::Base
  self.table_name = :portal_collaborations

  belongs_to :owner, :class_name => "Portal::Student", :foreign_key => "owner_id"

  has_many :collaboration_memberships, :class_name => "Portal::CollaborationMembership"
  has_many :students, :through => :collaboration_memberships, :class_name => "Portal::Student"
end
