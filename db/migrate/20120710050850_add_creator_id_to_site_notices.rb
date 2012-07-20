class AddCreatorIdToSiteNotices < ActiveRecord::Migration
  def self.up
    add_column :site_notices, :creator_id, :integer
  end

  def self.down
    remove_column :site_notices, :creator_id
  end
end
