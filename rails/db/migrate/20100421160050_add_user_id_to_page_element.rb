class AddUserIdToPageElement < ActiveRecord::Migration[5.1]
  def self.up
    add_column :page_elements, :user_id, :integer
  end

  def self.down
    remove_column :page_elements, :user_id
  end
end
