class AddFlagsToInteractive < ActiveRecord::Migration[5.1]
  def change
    add_column :interactives, :full_window, :boolean, :default => false
    add_column :interactives, :no_snapshots, :boolean, :default => false
  end
end
