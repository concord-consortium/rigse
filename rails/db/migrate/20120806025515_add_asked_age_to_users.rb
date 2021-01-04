class AddAskedAgeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :asked_age, :boolean, :default=>false
  end
end
