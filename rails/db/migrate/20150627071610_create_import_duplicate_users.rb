class CreateImportDuplicateUsers < ActiveRecord::Migration
  def up
    create_table :import_duplicate_users do |t|
     t.string  :login
     t.string  :email
     t.integer :duplicate_by
     t.text    :data
     t.integer :user_id
     t.integer :import_id
    end
  end

  def down
    drop_table :import_duplicate_users
  end
end