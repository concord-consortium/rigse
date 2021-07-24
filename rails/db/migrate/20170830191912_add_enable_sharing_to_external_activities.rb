class AddEnableSharingToExternalActivities < ActiveRecord::Migration[5.1]
  def change
    add_column :external_activities, :enable_sharing, :boolean, :default => true 
  end
end
