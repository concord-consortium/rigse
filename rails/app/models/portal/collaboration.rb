class Portal::Collaboration < ApplicationRecord
  self.table_name = :portal_collaborations

  belongs_to :owner, :class_name => "Portal::Student"
  belongs_to :offering, :class_name => "Portal::Offering"

  has_many :collaboration_memberships, :class_name => "Portal::CollaborationMembership"
  has_many :students, :through => :collaboration_memberships, :class_name => "Portal::Student"
end
