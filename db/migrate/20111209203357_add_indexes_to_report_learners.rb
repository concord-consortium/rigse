class AddIndexesToReportLearners < ActiveRecord::Migration
  def self.up
      add_index :report_learners, :school_id
      add_index :report_learners, :learner_id
      add_index :report_learners, :offering_id
      add_index :report_learners, :runnable_id
      add_index :report_learners, :class_id
      add_index :report_learners, :last_run
  end

  def self.down
      remove_index :report_learners, :school_id
      remove_index :report_learners, :learner_id
      remove_index :report_learners, :offering_id
      remove_index :report_learners, :runnable_id
      remove_index :report_learners, :class_id
      remove_index :report_learners, :last_run
  end
end
