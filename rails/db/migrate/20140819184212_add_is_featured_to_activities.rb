class AddIsFeaturedToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :is_featured, :boolean, :default => false
  end
end
