class CreateSparksActivities < ActiveRecord::Migration
  def self.up
    create_table :sparks_activities do |t|
      t.string :name, :limit => 72
      t.string :activity_url, :limit => 256
      t.string :save_url, :limit => 256
      t.integer :default_rubric_id
      t.integer :page_id
      t.timestamps
    end
  end

  def self.down
    drop_table :sparks_activities
  end
end

