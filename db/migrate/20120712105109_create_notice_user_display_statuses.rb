class CreateNoticeUserDisplayStatuses < ActiveRecord::Migration
  def self.up
    create_table :notice_user_display_statuses do |t|
      t.integer :user_id
      t.timestamp :last_collapsed_at_time
      t.boolean :collapsed_status
    end
  end

  def self.down
    drop_table :notice_user_display_statuses
  end
end
