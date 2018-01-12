class AddEnableSharingToExternalActivities < ActiveRecord::Migration
  def change
    add_column :external_activities, :enable_sharing, :boolean, :default => true 
  end
end
