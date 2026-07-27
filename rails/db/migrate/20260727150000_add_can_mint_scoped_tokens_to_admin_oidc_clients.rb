class AddCanMintScopedTokensToAdminOidcClients < ActiveRecord::Migration[8.0]
  def change
    add_column :admin_oidc_clients, :can_mint_scoped_tokens, :boolean, default: false, null: false
  end
end
