class AddRunnableTypeToReportLearners < ActiveRecord::Migration
  def self.up
    add_column :report_learners, :runnable_type, :string
  end

  def self.down
    remove_column :report_learners, :runnable_type
  end
end
