class AddConsoleLoggerIdAndBundleLoggerIdToPortalLearner < ActiveRecord::Migration
  def self.up
    add_column :portal_learners, :bundle_logger_id, :integer
    add_column :portal_learners, :console_logger_id, :integer
  end

  def self.down
    remove_column :portal_learners, :bundle_logger_id
    remove_column :portal_learners, :console_logger_id
  end
end
