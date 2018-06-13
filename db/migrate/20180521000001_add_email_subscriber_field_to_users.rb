class AddEmailSubscriberFieldToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_subscriber, :boolean, :default => false
  end
end
