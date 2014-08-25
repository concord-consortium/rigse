class AddAbstractToExternalActivities < ActiveRecord::Migration
  def change
    add_column :external_activities, :abstract, :text
  end
end
