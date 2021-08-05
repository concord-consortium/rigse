class RenameRestCreateUrlToLaunchUrl < ActiveRecord::Migration[5.1]
  def change
    rename_column :external_activities, :rest_create_url, :launch_url
  end
end
