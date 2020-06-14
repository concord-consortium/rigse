class CreateSiteNotices < ActiveRecord::Migration
  def self.up
    create_table :site_notices do |t|
      t.text :notice_html

      t.timestamps
    end
  end

  def self.down
    drop_table :site_notices
  end
end
