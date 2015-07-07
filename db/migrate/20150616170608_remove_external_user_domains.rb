class RemoveExternalUserDomains < ActiveRecord::Migration
  def up
    drop_table :external_user_domains
  end

  def down
    create_table :external_user_domains do |t|
      t.string :name
      t.text :description
      t.string :server_url
      t.string :uuid

      t.timestamps
    end
  end
end
