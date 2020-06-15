class AddHasPretestToExternalActivities < ActiveRecord::Migration
  def change
    add_column :external_activities, :has_pretest, :boolean, :default => false
  end
end
