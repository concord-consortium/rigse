class MakeReportLearnerAnswersLarger < ActiveRecord::Migration[5.1]
  def self.up
    change_column :report_learners, :answers, :text, :limit => 10.megabytes
  end

  def self.down
  end
end
