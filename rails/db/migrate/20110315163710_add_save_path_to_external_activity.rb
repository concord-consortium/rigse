class AddSavePathToExternalActivity < ActiveRecord::Migration
  def self.up
    add_column :external_activities, :save_path, :string
    add_index :external_activities, :save_path
  end

  def self.down
    remove_index :external_activities, :column => :save_path
    remove_column :external_activities, :save_path
  end
end
