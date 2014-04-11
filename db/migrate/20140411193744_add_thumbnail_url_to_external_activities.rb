class AddThumbnailUrlToExternalActivities < ActiveRecord::Migration
  def change
    add_column :external_activities, :thumbnail_url, :string
  end
end
