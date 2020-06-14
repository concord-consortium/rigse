class AddTeacherIdsToReportLearners < ActiveRecord::Migration
  def change
    add_column :report_learners, :teacher_ids, :string
  end
end
