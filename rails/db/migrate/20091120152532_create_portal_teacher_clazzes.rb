class CreatePortalTeacherClazzes < ActiveRecord::Migration
  def self.up
    create_table :portal_teacher_clazzes do |t|
      t.string    :uuid, :limit => 36
      t.string    :name
      t.text      :description
      
      t.datetime  :start_time
      t.datetime  :end_time
      
      t.integer   :clazz_id
      t.integer   :teacher_id

      t.timestamps
    end
    add_index     :portal_teacher_clazzes,  :clazz_id
    add_index     :portal_teacher_clazzes,  :teacher_id
  end

  def self.down
    drop_table :portal_teacher_clazzes
    remove_index     :portal_teacher_clazzes,  :clazz_id
    remove_index     :portal_teacher_clazzes,  :teacher_id
  end
end
