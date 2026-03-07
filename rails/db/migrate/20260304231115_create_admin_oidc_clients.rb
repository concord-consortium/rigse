class CreateAdminOidcClients < ActiveRecord::Migration[8.0]
  def change
    create_table :admin_oidc_clients do |t|
      t.string :name, null: false
      t.string :sub, null: false
      t.string :email
      t.integer :user_id, null: false
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    add_index :admin_oidc_clients, :sub, unique: true, name: 'index_admin_oidc_clients_on_sub'
    add_index :admin_oidc_clients, :user_id, name: 'index_admin_oidc_clients_on_user_id'
  end
end
