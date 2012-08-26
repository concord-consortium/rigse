# This migration comes from lightweight (originally 20120826174408)
class CreateLightweightMwInteractives < ActiveRecord::Migration
  def change
    create_table :lightweight_mw_interactives do |t|
      t.string :name
      t.string :url
      t.integer :user_id

      t.timestamps
    end

    add_index :lightweight_mw_interactives, :user_id, :name => 'mw_interactives_user_idx'
  end
end
