class AddIsFeaturedToExternalActivities < ActiveRecord::Migration[5.1]
  def change
    add_column :external_activities, :is_featured, :boolean, :default => false
  end
end
