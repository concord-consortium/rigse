class AddThumbnailUrlToInvestigations < ActiveRecord::Migration[5.1]
  def change
    add_column :investigations, :thumbnail_url, :string
  end
end
