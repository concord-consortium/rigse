class RenameSiteNotice < ActiveRecord::Migration[5.1]
  def up
    rename_table :site_notices , :admin_site_notices
  end

  def down
    rename_table :admin_site_notices , :site_notices
  end
end
