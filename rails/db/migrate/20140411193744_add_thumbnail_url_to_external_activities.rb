class AddThumbnailUrlToExternalActivities < ActiveRecord::Migration[5.1]
  def change
    add_column :external_activities, :thumbnail_url, :string
  end
end
