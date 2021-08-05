class ChangeHelpType < ActiveRecord::Migration[5.1]
  def up
    change_column :admin_projects, :help_type, :string
  end

  def down
    change_column :admin_projects, :help_type, :boolean
  end
end
