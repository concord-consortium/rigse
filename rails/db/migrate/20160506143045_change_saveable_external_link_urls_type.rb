class ChangeSaveableExternalLinkUrlsType < ActiveRecord::Migration
  def up
    change_column :saveable_external_link_urls, :url, :text
  end

  def down
    change_column :saveable_external_link_urls, :url, :string
  end
end
