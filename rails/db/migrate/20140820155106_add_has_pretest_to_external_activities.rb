class AddHasPretestToExternalActivities < ActiveRecord::Migration[5.1]
  def change
    add_column :external_activities, :has_pretest, :boolean, :default => false
  end
end
