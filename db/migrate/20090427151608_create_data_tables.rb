class CreateDataTables < ActiveRecord::Migration
  def self.up
    create_table :data_tables do |t|
      
      t.integer   "user_id"
      t.string    "uuid",        :limit => 36
      t.string    "name"
      t.text      "description"
      
      t.integer :column_count
      t.integer :visible_rows
      t.text :column_names
      t.text :column_data

      t.timestamps
    end
  end

  def self.down
    drop_table :data_tables
  end
end
