class DropLegacyTables < ActiveRecord::Migration[6.1]
  def up
    drop_table :learner_processing_events
    drop_table :portal_learner_activity_feedbacks
    drop_table :portal_offering_activity_feedbacks
    drop_table :portal_offering_embeddable_metadata
    drop_table :dataservice_blobs
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
