class CreateUserOfferingMetadata < ActiveRecord::Migration[8.0]
  def change
    create_table :user_offering_metadata do |t|
      t.integer :user_id, :null => false
      t.integer :offering_id, :null => false
      t.boolean :active, default: true
      t.boolean :locked, default: false

      t.timestamps
    end

    add_index :user_offering_metadata, [:user_id, :offering_id], unique: true, name: 'unique_user_offering_metadata'
  end
end
