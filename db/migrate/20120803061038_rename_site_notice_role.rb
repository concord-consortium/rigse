class RenameSiteNoticeRole < ActiveRecord::Migration
  def up
    rename_table :site_notice_roles, :admin_site_notice_roles
  end

  def down
    rename_table :admin_site_notice_roles, :site_notice_roles
  end
end
