class CreateExternalUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :type, :string
    add_column :users, :external_user_domain_id, :integer
    
    # The users table is now being used for single_table_inheritence
    # for Users and ExternalUsers.
    # Set the type of all existing records to 'User'
    User.connection.execute "UPDATE users SET type='User';"
  end

  def self.down
    remove_column :users, :type
    remove_column :users, :external_user_domain_id
  end
end
