class CreateLabBookSnapshots < ActiveRecord::Migration
  def self.up
    create_table :lab_book_snapshots do |t|
      
      t.integer   "user_id"
      t.string    "uuid",        :limit => 36
      t.string    "name"
      t.text      "description"
      
      t.text :target_element_type
      t.integer :target_element_id

      t.timestamps
    end
  end

  def self.down
    drop_table :lab_book_snapshots
  end
end
