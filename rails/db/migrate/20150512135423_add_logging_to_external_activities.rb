class AddLoggingToExternalActivities < ActiveRecord::Migration[5.1]
  def change
    add_column :external_activities, :logging, :boolean, :default => false
  end
end
