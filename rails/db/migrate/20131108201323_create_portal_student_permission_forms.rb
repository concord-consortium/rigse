class CreatePortalStudentPermissionForms < ActiveRecord::Migration[5.1]
  def change
    create_table :portal_student_permission_forms do |t|
      t.boolean :signed
      t.references :portal_student, index: false
      t.references :portal_permission_form, index: false
      t.timestamps
    end
    add_index :portal_student_permission_forms, :portal_student_id, :name => "p_s_p_student_id"
    add_index :portal_student_permission_forms, :portal_permission_form_id, :name => "p_s_p_form_id"
  end
end
