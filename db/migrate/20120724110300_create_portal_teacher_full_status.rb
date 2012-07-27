class CreatePortalTeacherFullStatus < ActiveRecord::Migration
  def up
    create_table :portal_teacher_full_status do |t|
      t.integer  :offering_id
      t.integer  :teacher_id
      t.boolean  :offering_collapsed
    end
    add_index :portal_teacher_full_status, :offering_id
    add_index :portal_teacher_full_status, :teacher_id
  end

  def down
    remove_index :portal_teacher_full_status, :offering_id
    remove_index :portal_teacher_full_status, :teacher_id
    
    drop_table :portal_teacher_full_status
  end
end
