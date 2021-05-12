class CreateAccessGrants < ActiveRecord::Migration[5.1]
  def change
    create_table :access_grants do |t|
      t.string :code
      t.string :access_token
      t.string :refresh_token
      t.datetime :access_token_expires_at
      t.integer :user_id
      t.integer :client_id
      t.string :state

      t.timestamps
    end
  end
end
