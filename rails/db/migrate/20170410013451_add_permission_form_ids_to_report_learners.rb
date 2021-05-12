class AddPermissionFormIdsToReportLearners < ActiveRecord::Migration[5.1]
  def change
    add_column :report_learners, :permission_form_ids, :string
  end
end
