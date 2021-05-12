class AddWrapHomePageContentToAdminSettings < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_settings, :wrap_home_page_content, :boolean, :default => true
  end
end
