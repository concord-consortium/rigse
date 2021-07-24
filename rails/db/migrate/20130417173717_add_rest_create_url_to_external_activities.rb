class AddRestCreateUrlToExternalActivities < ActiveRecord::Migration[5.1]
  def change
    add_column :external_activities, :rest_create_url, :string
  end
end
