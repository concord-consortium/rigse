class AddTeacherIdsToReportLearners < ActiveRecord::Migration[5.1]
  def change
    add_column :report_learners, :teacher_ids, :string
  end
end
