class AddToolIdToExternalActivities < ActiveRecord::Migration
  def change
    add_column :external_activities, :tool_id, :integer
  end
end
