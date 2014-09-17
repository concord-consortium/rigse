class Portal::Collaboration < ActiveRecord::Base
  # Owner
  belongs_to :student, :class_name => "Portal::Student", :foreign_key => "student_id"
  belongs_to :bundle_content, :class_name => "Dataservice::BundleContent", :foreign_key => "bundle_content_id"

  has_many :collaboration_memberships, :class_name => "Portal::CollaborationMembership"
  has_many :students, :through => :collaboration_memberships, :class_name => "Portal::Student"
end

