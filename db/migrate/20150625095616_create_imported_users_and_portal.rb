class CreateImportedUsersAndPortal < ActiveRecord::Migration
  def up

  	create_table :imported_users do |t|
      t.string     :user_url
      t.boolean    :is_verified
      t.integer    :user_id
      t.string     :importing_domain
      t.integer    :import_id
    end

  end

  def down
  	drop_table :imported_users
  end
end
