class AddCustomCssToAdminProject < ActiveRecord::Migration
  def self.up
    add_column :admin_projects, :custom_css, :text
  end

  def self.down
    remove_column :admin_projects, :custom_css
  end
end
