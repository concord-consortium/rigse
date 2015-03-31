class CreateInteractives < ActiveRecord::Migration
  def up
    create_table :interactives do |t|
      t.string :name
      t.text :description
      t.string :url
      t.float :width
      t.float :height
      t.float :scale
      t.string :image_url
      t.integer :user_ids
      t.string :credits
      t.timestamps
    end
  end
  def down
    drop_table :interactives
  end
end
