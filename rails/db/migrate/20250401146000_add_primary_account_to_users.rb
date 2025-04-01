class AddPrimaryAccountToUsers < ActiveRecord::Migration[6.1]

  def change
    add_reference :users, :primary_account, type: "int(11)", foreign_key: { to_table: :users }, index: true
  end
end
