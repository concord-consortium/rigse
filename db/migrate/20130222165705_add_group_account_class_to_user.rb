class AddGroupAccountClassToUser < ActiveRecord::Migration
  def change
    add_column :users, :group_account_class_id, :integer
  end
end
