class AddPermissionFormIdsToReportLearners < ActiveRecord::Migration
  def change
    add_column :report_learners, :permission_form_ids, :string
  end
end
