class Portal::CollaborationMembership < ActiveRecord::Base
  self.table_name = :portal_collaboration_memberships

  belongs_to :collaboration, :class_name => "Portal::Collaboration"
  belongs_to :student, :class_name => "Portal::Student"
end
