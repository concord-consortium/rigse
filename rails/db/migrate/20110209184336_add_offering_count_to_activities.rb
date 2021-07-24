class AddOfferingCountToActivities < ActiveRecord::Migration[5.1]
  def self.up
    add_column :activities, :offerings_count, :integer, :default => 0
  end

  def self.down
    remove_column :activities, :offerings_count
  end
end
