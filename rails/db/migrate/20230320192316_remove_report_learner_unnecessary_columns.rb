class RemoveReportLearnerUnnecessaryColumns < ActiveRecord::Migration[6.1]
  def up
    remove_column :report_learners, :answers

    remove_column :report_learners, :num_answerables
    remove_column :report_learners, :num_answered
    remove_column :report_learners, :num_correct
    remove_column :report_learners, :num_submitted
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
