class UpdateReportLearnerFields < ActiveRecord::Migration
  def change
    add_column :report_learners, :teachers_map, :text
    rename_column :report_learners, :teacher_ids, :teachers_id
    add_column :report_learners, :permission_forms_map, :text
    rename_column :report_learners, :permission_form_ids, :permission_forms_id
  end
end
