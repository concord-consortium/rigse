class CreateReportLearnerActivity < ActiveRecord::Migration
  def self.up
    create_table :report_learner_activity do |t|
      t.integer  :learner_id
      t.integer  :activity_id
      t.float   :complete_percent
    end
    add_index :report_learner_activity, :learner_id
    add_index :report_learner_activity, :activity_id
    
    learners = Report::Learner.all
    learners.each do |learner|
      report_util = Report::Util.new(learner, false, true)
      report_util.update_activity_completion_status
    end
  end

  def self.down
    remove_index :report_learner_activity, :learner_id
    remove_index :report_learner_activity, :activity_id
    
    drop_table :report_learner_activity
  end
end
