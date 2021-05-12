class AddSignUpPathToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :sign_up_path, :string
  end
end
