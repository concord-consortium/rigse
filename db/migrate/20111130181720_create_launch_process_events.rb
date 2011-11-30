class CreateLaunchProcessEvents < ActiveRecord::Migration
  def self.up
    create_table :launch_process_events do |t|
      t.string :event_type
      t.text :event_details

      t.integer :bundle_content_id

      t.timestamps
    end

    add_index :launch_process_events, :bundle_content_id
  end

  def self.down
    drop_table :launch_process_events
  end
end
