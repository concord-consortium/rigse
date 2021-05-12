class AddEmailSubscriberFieldToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :email_subscriber, :boolean, :default => false
  end
end
