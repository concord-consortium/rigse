class CreatePortalExternalUserDomains < ActiveRecord::Migration
  def self.up
    create_table :portal_external_user_domains do |t|
      t.string :name
      t.text :description
      t.string :server_url
      t.string :uuid

      t.timestamps
    end
  end

  def self.down
    drop_table :portal_external_user_domains
  end
end
