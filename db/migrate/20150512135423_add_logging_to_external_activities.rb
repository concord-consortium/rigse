class AddLoggingToExternalActivities < ActiveRecord::Migration
  def change
    add_column :external_activities, :logging, :boolean, :default => false
  end
end
