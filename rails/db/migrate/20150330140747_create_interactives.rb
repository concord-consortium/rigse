class CreateInteractives < ActiveRecord::Migration
  def up
    create_table :interactives do |t|
      t.string :name
      t.text :description
      t.string :url
      t.integer :width
      t.integer :height
      t.float :scale
      t.string :image_url
      t.integer :user_id
      t.string :credits
      t.string :publication_status
      t.timestamps
    end
  end
  def down
    drop_table :interactives
  end
end
