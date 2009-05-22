class AddCopiedFromToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :original_id, :integer
  end

  def self.down
    remove_column :activities, :original_id
  end
end
