class AddUpdatedByToSiteNotices < ActiveRecord::Migration[5.1]
  def self.up
    add_column :site_notices, :updated_by, :integer
  end

  def self.down
    remove_column :site_notices, :updated_by
  end
end
