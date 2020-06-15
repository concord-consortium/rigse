class MakeReportLearnerAnswersLarger < ActiveRecord::Migration
  def self.up
    change_column :report_learners, :answers, :text, :limit => 10.megabytes
  end

  def self.down
  end
end
