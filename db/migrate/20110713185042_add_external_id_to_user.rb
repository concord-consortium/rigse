class AddExternalIdToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :external_id, :string
  end

  def self.down
    remove_column :users, :external_id
  end
end
