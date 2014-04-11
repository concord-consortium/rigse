class AddThumbnailUrlToInvestigations < ActiveRecord::Migration
  def change
    add_column :investigations, :thumbnail_url, :string
  end
end
