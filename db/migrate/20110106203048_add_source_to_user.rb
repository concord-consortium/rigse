class AddSourceToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :source, :string
  end

  def self.down
    remove_column :users, :source
  end
end
