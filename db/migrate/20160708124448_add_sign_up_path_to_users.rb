class AddSignUpPathToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sign_up_path, :string
  end
end
