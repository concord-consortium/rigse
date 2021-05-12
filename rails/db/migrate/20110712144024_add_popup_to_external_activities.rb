class AddPopupToExternalActivities < ActiveRecord::Migration[5.1]
  def self.up
    add_column :external_activities, :popup, :boolean
  end

  def self.down
    remove_column :external_activities, :popup
  end
end
