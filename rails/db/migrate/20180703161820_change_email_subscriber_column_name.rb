class ChangeEmailSubscriberColumnName < ActiveRecord::Migration
  def change
    rename_column :users, :email_subscriber, :email_subscribed
  end
end
