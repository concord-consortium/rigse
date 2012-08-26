# This migration comes from lightweight (originally 20120826174118)
class CreateLightweightLightweightActivities < ActiveRecord::Migration
  def change
    create_table :lightweight_lightweight_activities do |t|
      t.string :name
      t.integer :user_id
      t.string :publication_status

      t.timestamps
    end

    add_index :lightweight_lightweight_activities, :user_id, :name => 'lightweight_activities_user_idx'
    add_index :lightweight_lightweight_activities, :publication_status, :name => 'lightweight_activities_publication_status_idx'
  end
end
