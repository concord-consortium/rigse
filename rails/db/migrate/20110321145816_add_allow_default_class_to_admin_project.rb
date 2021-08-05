class AddAllowDefaultClassToAdminProject < ActiveRecord::Migration[5.1]
  def self.up
    add_column :admin_projects, :allow_default_class, :boolean
  end

  def self.down
    remove_column :admin_projects, :allow_default_class
  end
end
