class AddNumSubmittedToReportLearners < ActiveRecord::Migration[5.1]
  def change
    add_column :report_learners, :num_submitted, :integer
  end
end
