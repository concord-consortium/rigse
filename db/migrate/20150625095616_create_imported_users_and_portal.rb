class CreateImportedUsersAndPortal < ActiveRecord::Migration
  def up

  	create_table :imported_users do |t|
      t.string     :user_url
      t.boolean    :is_verified
      t.integer    :user_id
      t.integer    :importing_portal_id
    end

    create_table :importing_portals do |t|
      t.string     :portal_url
    end

  end

  def down
  	drop_table :imported_users
  	drop_table :importing_portals
  end
end
