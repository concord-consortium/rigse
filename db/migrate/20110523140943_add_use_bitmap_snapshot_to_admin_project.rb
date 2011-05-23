class AddUseBitmapSnapshotToAdminProject < ActiveRecord::Migration
  def self.up
    add_column :admin_projects, :use_bitmap_snapshots, :boolean, :default => false
  end

  def self.down
    remove_column :admin_projects, :use_bitmap_snapshots
  end
end
