class AddFlagsToInteractive < ActiveRecord::Migration
  def change
    add_column :interactives, :full_window, :boolean, :default => false
    add_column :interactives, :no_snapshots, :boolean, :default => false
  end
end
