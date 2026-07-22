class AddForwardedJwtToAdminOidcClients < ActiveRecord::Migration[8.0]
  def change
    change_column_null :admin_oidc_clients, :user_id, true
    add_column :admin_oidc_clients, :requires_forwarded_jwt, :boolean, null: false, default: false
    add_column :admin_oidc_clients, :capabilities, :text
  end
end
