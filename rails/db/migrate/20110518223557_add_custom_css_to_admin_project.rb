class AddCustomCssToAdminProject < ActiveRecord::Migration[5.1]
  def self.up
    add_column :admin_projects, :custom_css, :text
  end

  def self.down
    remove_column :admin_projects, :custom_css
  end
end
