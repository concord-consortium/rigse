class AddNumSubmittedToReportLearners < ActiveRecord::Migration
  def change
    add_column :report_learners, :num_submitted, :integer
  end
end
