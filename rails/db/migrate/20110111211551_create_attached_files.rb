class CreateAttachedFiles < ActiveRecord::Migration
  def self.up
    create_table :attached_files do |t|
      t.integer :user_id
      t.string :name
      t.string :attachable_type
      t.integer :attachable_id

      # Paperclip Attachments
      t.string :attachment_file_name
      t.string :attachment_content_type
      t.integer :attachment_file_size
      t.datetime :attachment_updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :attached_files
  end
end
