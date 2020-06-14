class AddFirebaseApps < ActiveRecord::Migration
  def change
    create_table :firebase_apps do |t|
      t.string :name
      t.string :client_email
      t.text :private_key
      t.timestamps
    end
    add_index :firebase_apps, :name
  end
end
