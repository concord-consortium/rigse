class AddTeachersCanAuthorToAdminProject < ActiveRecord::Migration
  def self.up
    add_column :admin_projects, :teachers_can_author, :boolean, :default => true
  end

  def self.down
    remove_column :admin_projects, :teachers_can_author
  end
end
