class AddPermissionFormsToReportLearner < ActiveRecord::Migration
  def change
    add_column :report_learners, :permission_forms, :text
  end
end
