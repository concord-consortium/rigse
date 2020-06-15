class AddRestCreateUrlToExternalActivities < ActiveRecord::Migration
  def change
    add_column :external_activities, :rest_create_url, :string
  end
end
