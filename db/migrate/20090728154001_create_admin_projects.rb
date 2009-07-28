class CreateAdminProjects < ActiveRecord::Migration
  def self.up
    create_table :admin_projects do |t|
      t.integer :user_id
      t.string :name
      t.string :url
      t.text :description
      t.text :states_and_provinces
      t.integer :maven_jnlp_server_id
      t.integer :maven_jnlp_family_id
      t.string :jnlp_version_str
      t.boolean :snapshot_enabled
      t.boolean :enable_default_users
      
      t.string :uuid, :limit => 36

      t.timestamps
    end
  end

  def self.down
    drop_table :admin_projects
  end
end
