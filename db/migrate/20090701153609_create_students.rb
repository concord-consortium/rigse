class CreateStudents < ActiveRecord::Migration
  def self.up
    create_table :portal_students do |t|

      t.string    :uuid, :limit => 36
      t.string    :name
      t.text      :description
      
      t.integer   :user_id
      t.integer   :grade_level_id

      t.timestamps
    end
  end

  def self.down
    drop_table :portal_students
  end
end
