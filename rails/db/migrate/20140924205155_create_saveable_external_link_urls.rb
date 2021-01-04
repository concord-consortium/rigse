class CreateSaveableExternalLinkUrls < ActiveRecord::Migration
  def change
    create_table :saveable_external_link_urls do |t|
      t.integer :external_link_id
      t.integer :bundle_content_id
      t.integer :position
      t.string  :url
      t.boolean :is_final

      t.timestamps
    end
  end
end
