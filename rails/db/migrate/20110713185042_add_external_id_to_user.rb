class AddExternalIdToUser < ActiveRecord::Migration[5.1]
  def self.up
    add_column :users, :external_id, :string
  end

  def self.down
    remove_column :users, :external_id
  end
end
