class AddUidProviderIndexToAuthentications < ActiveRecord::Migration[6.1]
  def change
    add_index :authentications, [:provider, :uid]
    add_index :access_grants, :access_token
  end
end
