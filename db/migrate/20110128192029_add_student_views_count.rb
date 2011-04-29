class AddStudentViewsCount < ActiveRecord::Migration
  def self.up
    create_table :student_views do |t|
      t.integer :user_id, :null => false
      t.integer :viewable_id, :null => false
      t.string  :viewable_type, :null => false
      t.integer :count
    end

    add_index :student_views, [:user_id, :viewable_id, :viewable_type]
  end

  def self.down
    drop_table :student_views
  end
end
