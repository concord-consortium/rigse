class ChangeEmailSubscriberColumnName < ActiveRecord::Migration[5.1]
  def change
    rename_column :users, :email_subscriber, :email_subscribed
  end
end
