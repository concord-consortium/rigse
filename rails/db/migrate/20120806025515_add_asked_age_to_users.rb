class AddAskedAgeToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :asked_age, :boolean, :default=>false
  end
end
