class AddCustomSearchPathToAdminSettings < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_settings, :custom_search_path, :string, :default => "/search"
  end
end
