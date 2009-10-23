class CreatePortalExternalUsers < ActiveRecord::Migration
  def self.up
    create_table :portal_external_users do |t|
      t.integer :external_user_domain_id
      t.integer :user_id
      t.string :external_user_key
      t.string :uuid

      t.timestamps
    end
  end

  def self.down
    drop_table :portal_external_users
  end
end
