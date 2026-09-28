class AddScopesAndPkceToOauth < ActiveRecord::Migration[8.0]
  def change
    # Space-separated capabilities the client may request (TokenCapabilities).
    add_column :clients, :scopes, :text

    # What an authorization code was issued for, checked when it is redeemed. One ALTER
    # rather than five, since access_grants holds a row per user and client.
    change_table :access_grants, bulk: true do |t|
      t.string  :code_challenge
      t.text    :redirect_uri
      t.text    :scope
      t.string  :context_type
      t.integer :context_id
    end
  end
end
