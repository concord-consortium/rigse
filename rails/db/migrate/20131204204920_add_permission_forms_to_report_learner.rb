class AddPermissionFormsToReportLearner < ActiveRecord::Migration[5.1]
  def change
    add_column :report_learners, :permission_forms, :text
  end
end
