class CreateDrawingTools < ActiveRecord::Migration
  def self.up
    create_table :drawing_tools do |t|
      
      t.integer   "user_id"
      t.string    "uuid",        :limit => 36
      t.string    "name"
      t.text      "description"
      
      t.string :background_image_url
      t.string :stamps
      t.boolean :is_grid_visible
      t.integer :preferred_width
      t.integer :preferred_height

      t.timestamps
    end
  end

  def self.down
    drop_table :drawing_tools
  end
end
