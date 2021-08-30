class RemoveLaunchUrlFromExternalActivities < ActiveRecord::Migration[6.1]
  def change
    remove_column :external_activities, :launch_url
  end
end
