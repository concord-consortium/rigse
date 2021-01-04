class EnsureReportLearnersHasIndexes < ActiveRecord::Migration
  def self.up
    # remove them first, just in case they exist.
    # rescue errors, in case they don't.
    remove_index :report_learners, :school_id rescue nil
    remove_index :report_learners, :learner_id rescue nil
    remove_index :report_learners, :offering_id rescue nil
    remove_index :report_learners, :runnable_id rescue nil
    remove_index :report_learners, :class_id rescue nil
    remove_index :report_learners, :last_run rescue nil

    # add them in
    add_index :report_learners, :school_id
    add_index :report_learners, :learner_id
    add_index :report_learners, :offering_id
    add_index :report_learners, :runnable_id
    add_index :report_learners, :class_id
    add_index :report_learners, :last_run
  end

  def self.down
    # don't bother removing them, since the migration earlier has
    # been modified to add/remove them.
  end
end
