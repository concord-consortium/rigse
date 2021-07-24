class AddAnswersToReportLearner < ActiveRecord::Migration[5.1]
  def self.up
    add_column :report_learners, :answers, :text
  end

  def self.down
    remove_column :report_learners, :answers
  end
end
