class CreateStudentClazzes < ActiveRecord::Migration
  def self.up
    create_table :portal_student_clazzes do |t|

      t.string    :uuid, :limit => 36
      t.string    :name
      t.text      :description
      
      t.datetime  :start_time
      t.datetime  :end_time
      
      t.integer   :clazz_id
      t.integer   :student_id

      t.timestamps
    end
  end

  def self.down
    drop_table :portal_student_clazzes
  end
end
