class AddAppendAuthTokenToExternalActivity < ActiveRecord::Migration
  def self.up
    add_column :external_activities, :append_auth_token, :boolean
  end

  def self.down
    remove_column :external_activities, :append_auth_token
  end
end
