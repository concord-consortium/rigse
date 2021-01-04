class CreateSiteNoticeRoles < ActiveRecord::Migration
  def self.up
    create_table :site_notice_roles do |t|
      t.integer :notice_id
      t.integer :role_id

      t.timestamps
    end
  end

  def self.down
    drop_table :site_notice_roles
  end
end
