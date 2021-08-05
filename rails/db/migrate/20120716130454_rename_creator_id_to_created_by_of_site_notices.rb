class RenameCreatorIdToCreatedByOfSiteNotices < ActiveRecord::Migration[5.1]
  def self.up
    rename_column :site_notices, :creator_id, :created_by
  end

  def self.down
    rename_column :site_notices, :created_by, :creator_id
  end
end
