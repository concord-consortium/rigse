class ChangeHelpType < ActiveRecord::Migration
  def up
    change_column :admin_projects, :help_type, :string
  end

  def down
    change_column :admin_projects, :help_type, :boolean
  end
end
