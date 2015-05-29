class CreateJoinTableAdminProjectUsers < ActiveRecord::Migration
  def change
    create_table :admin_project_users, :id => false do |t|
      t.integer :project_id
      t.integer :user_id
    end
    add_index :admin_project_users, :project_id
    add_index :admin_project_users, :user_id
    add_index :admin_project_users, [:project_id, :user_id], unique: true, name: 'admin_proj_user_uniq_idx'
  end
end
