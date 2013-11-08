class CreatePortalStudentPermissionForms < ActiveRecord::Migration
  def change
    create_table :portal_student_permission_forms do |t|
      t.boolean :signed
      t.references :portal_student
      t.references :portal_permission_form
      t.timestamps
    end
    add_index :portal_student_permission_forms, :portal_student_id
    add_index :portal_student_permission_forms, :portal_permission_form_id, :name => "p_s_p_form_id"
  end
end


