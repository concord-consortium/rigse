class AddIsFeaturedToExternalActivities < ActiveRecord::Migration
  def change
    add_column :external_activities, :is_featured, :boolean, :default => false
  end
end
