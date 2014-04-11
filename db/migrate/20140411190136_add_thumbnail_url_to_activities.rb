class AddThumbnailUrlToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :thumbnail_url, :string
  end
end
