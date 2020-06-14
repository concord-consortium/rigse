class DropAdminSiteNoticesRolesTable < ActiveRecord::Migration
  def up
    drop_table :admin_site_notice_roles
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
