class AddIsLockedToExternalActivity < ActiveRecord::Migration
  def change
    add_column :external_activities, :is_locked, :boolean
  end
end
