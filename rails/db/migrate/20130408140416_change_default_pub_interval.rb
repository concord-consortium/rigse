class ChangeDefaultPubInterval < ActiveRecord::Migration[5.1]
  def up
    change_column :admin_projects, :pub_interval, :integer, :default => 10
  end

  def down
    change_column :admin_projects, :pub_interval, :integer, :default => 300
  end
end
