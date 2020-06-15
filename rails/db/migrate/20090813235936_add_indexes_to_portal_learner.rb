class AddIndexesToPortalLearner < ActiveRecord::Migration
  def self.up
    add_index :portal_learners, :offering_id
    add_index :portal_learners, :bundle_logger_id
    add_index :portal_learners, :console_logger_id
  end

  def self.down
    remove_index :portal_learners, :offering_id
    remove_index :portal_learners, :bundle_logger_id
    remove_index :portal_learners, :console_logger_id
  end
end
