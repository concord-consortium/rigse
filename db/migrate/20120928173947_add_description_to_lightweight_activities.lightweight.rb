# This migration comes from lightweight (originally 20120928173217)
class AddDescriptionToLightweightActivities < ActiveRecord::Migration
  def change
    add_column :lightweight_lightweight_activities, :description, :text, :null => true
  end
end
