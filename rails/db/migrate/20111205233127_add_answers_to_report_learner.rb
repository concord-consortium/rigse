class AddAnswersToReportLearner < ActiveRecord::Migration
  def self.up
    add_column :report_learners, :answers, :text
  end

  def self.down
    remove_column :report_learners, :answers
  end
end
