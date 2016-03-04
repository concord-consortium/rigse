class AddWrapHomePageContentToAdminSettings < ActiveRecord::Migration
  def change
    add_column :admin_settings, :wrap_home_page_content, :boolean, :default => true
  end
end
