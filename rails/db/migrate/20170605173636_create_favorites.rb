class CreateFavorites < ActiveRecord::Migration
  
  def change
    create_table :favorites do |t|
      t.references :user
      t.references :favoritable, :polymorphic => true
      t.timestamps
    end

    add_index :favorites, :favoritable_id
    add_index :favorites, :favoritable_type

    #
    # Specify the index name here, otherwise what rails generates is
    # too long for MySQL. 
    #
    add_index :favorites, [:user_id, :favoritable_id, :favoritable_type], unique: true, name: "favorite_unique"

  end

end
