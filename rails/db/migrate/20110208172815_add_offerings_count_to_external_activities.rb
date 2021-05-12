class AddOfferingsCountToExternalActivities < ActiveRecord::Migration[5.1]
  def self.up
    add_column :external_activities, :offerings_count, :integer, :default => 0
  end

  def self.down
    remove_column :external_activities, :offerings_count
  end
end
