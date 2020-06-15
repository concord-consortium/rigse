class AddLaraAndPortalDurations < ActiveRecord::Migration
  def up
    add_column :learner_processing_events, :lara_duration,   :integer
    add_column :learner_processing_events, :portal_duration, :integer
  end

  def down
    remove_column :learner_processing_events, :lara_duration
    remove_column :learner_processing_events, :portal_duration
  end
end
