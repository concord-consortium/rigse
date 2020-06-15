class CreateTeachers < ActiveRecord::Migration
  def self.up
    create_table :portal_teachers do |t|

      t.string    :uuid, :limit => 36
      t.string    :name
      t.text      :description
      
      t.integer   :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :portal_teachers
  end
end
