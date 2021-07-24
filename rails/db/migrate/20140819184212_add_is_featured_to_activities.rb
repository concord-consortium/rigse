class AddIsFeaturedToActivities < ActiveRecord::Migration[5.1]
  def change
    add_column :activities, :is_featured, :boolean, :default => false
  end
end
