class AddAllowCollaborationToExternalActivities < ActiveRecord::Migration
  def change
    add_column :external_activities, :allow_collaboration, :boolean, default: false
  end
end
