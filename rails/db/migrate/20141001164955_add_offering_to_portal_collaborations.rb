class AddOfferingToPortalCollaborations < ActiveRecord::Migration
  class Dataservice::BundleContent < ActiveRecord::Base
    self.table_name = :dataservice_bundle_contents
    belongs_to :collaboration, :class_name => "Portal::Collaboration"
    belongs_to :bundle_logger, :class_name => "Dataservice::BundleLogger", :foreign_key => "bundle_logger_id"
    delegate :learner, :to => :bundle_logger, :allow_nil => true
  end
  class Dataservice::BundleLogger < ActiveRecord::Base
    self.table_name = :dataservice_bundle_loggers
    has_one :learner, :class_name => "Portal::Learner"
  end
  class Portal::Learner < ActiveRecord::Base
    self.table_name = :portal_learners
    belongs_to :offering, :class_name => "Portal::Offering", :foreign_key => "offering_id"
  end
  class Portal::Collaboration < ActiveRecord::Base
    self.table_name = :portal_collaborations
    has_one :bundle_content, :class_name => "Dataservice::BundleContent"
    belongs_to :offering, :class_name => "Portal::Offering"
  end

  def up
    add_column :portal_collaborations, :offering_id, :integer

    # Add this index temporarily, so the processing below can work reasonably fast.
    # This index will be added permanently in the next migration.
    add_index :dataservice_bundle_contents, :collaboration_id

    # Update offering_id in existing collaborations using bundle_contents.
    Portal::Learner.reset_column_information
    Dataservice::BundleLogger.reset_column_information
    Dataservice::BundleContent.reset_column_information
    Portal::Collaboration.reset_column_information

    Portal::Collaboration.find_each do |collaboration|
      bundle = collaboration.bundle_content
      learner = bundle && bundle.learner
      offering = learner && learner.offering
      next unless offering
      collaboration.offering = offering
      collaboration.save!
    end

    remove_index :dataservice_bundle_contents, :collaboration_id
  end

  def down
    remove_column :portal_collaborations, :offering_id
  end
end
