class GenerateCollaborationsUsingLegacyCollaborations < ActiveRecord::Migration
  class Portal::Student < ActiveRecord::Base
    self.table_name = :portal_students
  end
  class Portal::Learner < ActiveRecord::Base
    self.table_name = :portal_learners
    belongs_to :student, :class_name => "Portal::Student", :foreign_key => "student_id"
  end
  class Dataservice::BundleLogger < ActiveRecord::Base
    self.table_name = :dataservice_bundle_loggers
    has_one :learner, :class_name => "Portal::Learner"
  end
  class Dataservice::BundleContent < ActiveRecord::Base
    self.table_name = :dataservice_bundle_contents
    belongs_to :bundle_logger, :class_name => "Dataservice::BundleLogger", :foreign_key => "bundle_logger_id"
    has_many :legacy_collaborations, :dependent => :destroy, :class_name => "Portal::LegacyCollaboration", :foreign_key => "bundle_content_id"
    has_many :collaborators, :through => :legacy_collaborations, :class_name => "Portal::Student", :source => :student
  end
    class Portal::LegacyCollaboration < ActiveRecord::Base
    self.table_name = :legacy_collaborations
    belongs_to :student, :class_name => "Portal::Student", :foreign_key => "student_id"
    belongs_to :bundle_content, :class_name => "Dataservice::BundleContent", :foreign_key => "bundle_content_id"
  end
  class Portal::CollaborationMembership < ActiveRecord::Base
    self.table_name = :portal_collaboration_memberships
    belongs_to :collaboration, :class_name => "Portal::Collaboration"
    belongs_to :student, :class_name => "Portal::Student"
  end
  class Portal::Collaboration < ActiveRecord::Base
    self.table_name = :portal_collaborations
    has_many :collaboration_memberships, :class_name => "Portal::CollaborationMembership"
    has_many :students, :through => :collaboration_memberships, :class_name => "Portal::Student"
  end

  def up
    Portal::Student.reset_column_information
    Portal::Learner.reset_column_information
    Dataservice::BundleLogger.reset_column_information
    Dataservice::BundleContent.reset_column_information
    Portal::LegacyCollaboration.reset_column_information
    Portal::CollaborationMembership.reset_column_information
    Portal::Collaboration.reset_column_information

    # decrease batch size for tempormental hosts.
    # eagerly load associations to be faster
    Dataservice::BundleContent.find_each(
    :include => [
       {:bundle_logger => {:learner => :student}},
       :collaborators
     ], :batch_size => 250) do |bundle|
       collaborators = bundle.collaborators
       next if collaborators.size == 0
       next if bundle.bundle_logger.learner.nil?
       owner_id = bundle.bundle_logger.learner.student.id
       collaboration = Portal::Collaboration.create(:owner_id => owner_id)
       collaboration.students = collaborators
       bundle.update_attributes!(:collaboration_id => collaboration.id)
    end
  end

  def down
    Portal::Collaboration.delete_all
    Portal::CollaborationMembership.delete_all
    Dataservice::BundleContent.update_all(:collaboration_id => nil)
  end
end
