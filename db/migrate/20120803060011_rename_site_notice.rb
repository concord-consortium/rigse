class RenameSiteNotice < ActiveRecord::Migration
  def up
    rename_table :site_notices , :admin_site_notices
  end

  def down
    rename_table :admin_site_notices , :site_notices
  end
end
