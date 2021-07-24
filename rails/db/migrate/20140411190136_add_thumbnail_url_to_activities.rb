class AddThumbnailUrlToActivities < ActiveRecord::Migration[5.1]
  def change
    add_column :activities, :thumbnail_url, :string
  end
end
