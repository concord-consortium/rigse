class Portal::CollaborationMembership < ActiveRecord::Base
  belongs_to :collaboration, :class_name => "Portal::Collaboration"
  belongs_to :student, :class_name => "Portal::Student"
end
