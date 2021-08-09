class AddRemoteDuplicateUrlToTools < ActiveRecord::Migration[6.1]
  def change
    add_column :tools, :remote_duplicate_url, :string
  end
end
