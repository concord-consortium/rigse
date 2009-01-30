class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.integer :parent_id
      t.string :content_type
      t.string :filename
      t.string :thumbnail
      t.integer :size
      t.integer :width
      t.integer :height
      t.string :description
      t.column :uuid, :string, :limit => 36

      t.timestamps
    end
  end

  def self.down
    drop_table :images
  end
end
