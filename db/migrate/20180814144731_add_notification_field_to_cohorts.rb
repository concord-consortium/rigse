class AddNotificationFieldToCohorts < ActiveRecord::Migration
  def up
    add_column :admin_cohorts, :email_notifications_enabled, :boolean, :default => false
  end

  def down
    remove_column :admin_cohorts, :email_notifications_enabled
  end
end
