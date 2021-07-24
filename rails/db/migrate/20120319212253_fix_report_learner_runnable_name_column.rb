class FixReportLearnerRunnableNameColumn < ActiveRecord::Migration[5.1]
  def self.up
    change_column :report_learners, :runnable_name, :string
  end

  def self.down
  end
end
