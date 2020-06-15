class CreateSiteNoticeUsers < ActiveRecord::Migration
  def self.up
    create_table :site_notice_users do |t|
      t.integer :notice_id
      t.integer :user_id
      t.boolean :notice_dismissed

      t.timestamps
    end
  end

  def self.down
    drop_table :site_notice_users
  end
end
