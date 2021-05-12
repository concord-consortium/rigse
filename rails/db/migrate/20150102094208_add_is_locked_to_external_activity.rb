class AddIsLockedToExternalActivity < ActiveRecord::Migration[5.1]
  def change
    add_column :external_activities, :is_locked, :boolean
  end
end
