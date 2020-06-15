class CreateClazzes < ActiveRecord::Migration
  def self.up
    create_table :portal_clazzes do |t|

      t.string    :uuid, :limit => 36
      t.string    :name
      t.text      :description
      
      t.datetime  :start_time
      t.datetime  :end_time
      
      t.string    :class_word
      t.string    :status
      
      t.integer   :course_id
      t.integer   :semester_id
      t.integer   :teacher_id

      t.timestamps
    end
  end

  def self.down
    drop_table :portal_clazzes
  end
end
